/**
 * @name Unresolved import
 * @description An unresolved import may result in reduced coverage and accuracy of analysis.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

// 导入Python分析库
import python

/**
 * 定位在条件分支中可能作为备选的导入语句
 * 当两个导入语句位于条件分支的不同路径中时，它们可能互为替代方案
 */
ImportExpr findAlternativeImport(ImportExpr targetImport) {
  // 检查是否存在别名映射，使得目标导入表达式或其成员模块与结果表达式相关联
  exists(Alias primaryAlias, Alias secondaryAlias |
    (primaryAlias.getValue() = targetImport or primaryAlias.getValue().(ImportMember).getModule() = targetImport) and
    (secondaryAlias.getValue() = result or secondaryAlias.getValue().(ImportMember).getModule() = result) and
    (
      // 检查if语句的两个分支是否分别包含目标导入表达式和结果表达式
      exists(If conditionalStmt | 
        conditionalStmt.getBody().contains(targetImport) and conditionalStmt.getOrelse().contains(result)
        or
        conditionalStmt.getBody().contains(result) and conditionalStmt.getOrelse().contains(targetImport)
      )
      or
      // 检查try语句的主体和异常处理块是否分别包含目标导入表达式和结果表达式
      exists(Try exceptionBlock | 
        exceptionBlock.getBody().contains(targetImport) and exceptionBlock.getAHandler().contains(result)
        or
        exceptionBlock.getBody().contains(result) and exceptionBlock.getAHandler().contains(targetImport)
      )
    )
  )
}

/**
 * 判断导入表达式是否与特定操作系统相关
 * 返回对应的操作系统名称，如果不匹配任何已知模式则返回空字符串
 */
string getOSSpecificImport(ImportExpr targetImport) {
  exists(string importedModuleName | importedModuleName = targetImport.getImportedModuleName() |
    // Java平台相关的模块
    (importedModuleName.matches("org.python.%") or importedModuleName.matches("java.%")) and result = "java"
    or
    // macOS (Darwin)平台相关的模块
    importedModuleName.matches("Carbon.%") and result = "darwin"
    or
    // Windows平台相关的模块
    result = "win32" and
    (
      importedModuleName = "_winapi" or
      importedModuleName = "_win32api" or
      importedModuleName = "_winreg" or
      importedModuleName = "nt" or
      importedModuleName.matches("win32%") or
      importedModuleName = "ntpath"
    )
    or
    // Linux平台相关的模块
    result = "linux2" and
    (importedModuleName = "posix" or importedModuleName = "posixpath")
    or
    // 不支持的平台相关的模块
    result = "unsupported" and
    (importedModuleName = "__pypy__" or importedModuleName = "ce" or importedModuleName.matches("riscos%"))
  )
}

/**
 * 获取当前运行的操作系统平台信息
 * 通过检查sys.platform的值来确定当前操作系统
 */
string getCurrentOS() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * 判断导入表达式是否被允许失败
 * 如果存在替代导入方案，或者导入表达式是针对特定操作系统但与当前系统不匹配，则允许失败
 */
predicate isImportAllowedToFail(ImportExpr targetImport) {
  // 存在可用的替代导入表达式
  findAlternativeImport(targetImport).refersTo(_)
  or
  // 导入表达式是特定操作系统相关的，但与当前操作系统不匹配
  getOSSpecificImport(targetImport) != getCurrentOS()
}

/**
 * 表示Python版本测试节点的类
 * 这些节点通常用于检查Python解释器的版本信息
 */
class PythonVersionTest extends ControlFlowNode {
  PythonVersionTest() {
    // 检查节点是否引用了sys模块的版本相关属性
    exists(string versionAttrName |
      versionAttrName.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionAttrName))
    )
  }

  override string toString() { result = "VersionTest" }
}

/**
 * 表示Python版本保护块的类
 * 这些代码块根据Python版本条件控制代码执行路径
 */
class PythonVersionGuard extends ConditionBlock {
  PythonVersionGuard() { 
    // 检查条件块的最后一个节点是否是版本测试节点
    this.getLastNode() instanceof PythonVersionTest 
  }
}

// 主查询：查找无法解析且不应失败的导入表达式
from ImportExpr problematicImport
where
  // 导入表达式无法解析为任何模块
  not problematicImport.refersTo(_) and 
  // 导入表达式存在于有效的分析上下文中
  exists(Context context | context.appliesTo(problematicImport.getAFlowNode())) and 
  // 导入表达式不被允许失败
  not isImportAllowedToFail(problematicImport) and 
  // 导入表达式不受版本保护块的控制
  not exists(PythonVersionGuard versionGuard | versionGuard.controls(problematicImport.getAFlowNode().getBasicBlock(), _))
// 选择符合条件的导入表达式并生成问题描述
select problematicImport, "Unable to resolve import of '" + problematicImport.getImportedModuleName() + "'."