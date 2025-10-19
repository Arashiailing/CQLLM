/**
 * @name Unresolved import
 * @description An unresolved import may result in reduced coverage and accuracy of analysis.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

// 导入Python库
import python

// 定义一个函数，用于查找替代的导入表达式
ImportExpr alternative_import(ImportExpr ie) {
  // 检查是否存在别名，使得当前导入表达式或其成员模块与结果匹配
  exists(Alias thisalias, Alias otheralias |
    (thisalias.getValue() = ie or thisalias.getValue().(ImportMember).getModule() = ie) and
    (otheralias.getValue() = result or otheralias.getValue().(ImportMember).getModule() = result) and
    (
      // 检查if语句中是否包含当前导入表达式和结果
      exists(If i | i.getBody().contains(ie) and i.getOrelse().contains(result))
      or
      exists(If i | i.getBody().contains(result) and i.getOrelse().contains(ie))
      or
      // 检查try语句中是否包含当前导入表达式和结果
      exists(Try t | t.getBody().contains(ie) and t.getAHandler().contains(result))
      or
      exists(Try t | t.getBody().contains(result) and t.getAHandler().contains(ie))
    )
  )
}

// 定义一个函数，用于判断导入表达式是否是特定操作系统相关的
string os_specific_import(ImportExpr ie) {
  // 检查导入模块名称是否匹配特定的模式，并返回相应的操作系统名称
  exists(string name | name = ie.getImportedModuleName() |
    name.matches("org.python.%") and result = "java"
    or
    name.matches("java.%") and result = "java"
    or
    name.matches("Carbon.%") and result = "darwin"
    or
    result = "win32" and
    (
      name = "_winapi" or
      name = "_win32api" or
      name = "_winreg" or
      name = "nt" or
      name.matches("win32%") or
      name = "ntpath"
    )
    or
    result = "linux2" and
    (name = "posix" or name = "posixpath")
    or
    result = "unsupported" and
    (name = "__pypy__" or name = "ce" or name.matches("riscos%"))
  )
}

// 获取操作系统平台信息
string get_os() { py_flags_versioned("sys.platform", result, major_version().toString()) }

// 定义一个谓词，用于判断导入表达式是否可以失败
predicate ok_to_fail(ImportExpr ie) {
  // 如果存在替代的导入表达式或者导入表达式是特定操作系统相关的且不匹配当前操作系统，则可以失败
  alternative_import(ie).refersTo(_)
  or
  os_specific_import(ie) != get_os()
}

// 定义一个类，用于表示版本测试节点
class VersionTest extends ControlFlowNode {
  // 构造函数，检查节点是否指向系统模块的版本属性
  VersionTest() {
    exists(string name |
      name.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(name))
    )
  }

  // 重写toString方法，返回类的名称
  override string toString() { result = "VersionTest" }
}

/** A guard on the version of the Python interpreter */
// 定义一个类，用于表示版本保护块
class VersionGuard extends ConditionBlock {
  // 构造函数，检查最后一个节点是否是版本测试节点
  VersionGuard() { this.getLastNode() instanceof VersionTest }
}

// 从导入表达式开始查询，条件为：无法解析的导入表达式，并且不存在适用的版本保护块
from ImportExpr ie
where
  not ie.refersTo(_) and // 导入表达式无法解析
  exists(Context c | c.appliesTo(ie.getAFlowNode())) and // 存在适用的上下文
  not ok_to_fail(ie) and // 导入表达式不可以失败
  not exists(VersionGuard guard | guard.controls(ie.getAFlowNode().getBasicBlock(), _)) // 不存在适用的版本保护块
select ie, "Unable to resolve import of '" + ie.getImportedModuleName() + "'." // 选择无法解析的导入表达式并输出提示信息
