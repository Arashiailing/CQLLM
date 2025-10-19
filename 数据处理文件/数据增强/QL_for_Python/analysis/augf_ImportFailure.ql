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
 * 查找可能作为替代方案的导入表达式
 * 当两个导入表达式位于条件分支的不同路径中时，它们可能互为替代方案
 */
ImportExpr findAlternativeImport(ImportExpr importExpr) {
  // 检查是否存在别名映射，使得当前导入表达式或其成员模块与结果表达式相关联
  exists(Alias currentAlias, Alias alternativeAlias |
    (currentAlias.getValue() = importExpr or currentAlias.getValue().(ImportMember).getModule() = importExpr) and
    (alternativeAlias.getValue() = result or alternativeAlias.getValue().(ImportMember).getModule() = result) and
    (
      // 检查if语句的两个分支是否分别包含当前导入表达式和结果表达式
      exists(If ifStmt | ifStmt.getBody().contains(importExpr) and ifStmt.getOrelse().contains(result))
      or
      exists(If ifStmt | ifStmt.getBody().contains(result) and ifStmt.getOrelse().contains(importExpr))
      or
      // 检查try语句的主体和异常处理块是否分别包含当前导入表达式和结果表达式
      exists(Try tryStmt | tryStmt.getBody().contains(importExpr) and tryStmt.getAHandler().contains(result))
      or
      exists(Try tryStmt | tryStmt.getBody().contains(result) and tryStmt.getAHandler().contains(importExpr))
    )
  )
}

/**
 * 判断导入表达式是否与特定操作系统相关
 * 返回对应的操作系统名称，如果不匹配任何已知模式则返回空字符串
 */
string getOSSpecificImport(ImportExpr importExpr) {
  exists(string moduleName | moduleName = importExpr.getImportedModuleName() |
    // Java平台相关的模块
    (moduleName.matches("org.python.%") or moduleName.matches("java.%")) and result = "java"
    or
    // macOS (Darwin)平台相关的模块
    moduleName.matches("Carbon.%") and result = "darwin"
    or
    // Windows平台相关的模块
    result = "win32" and
    (
      moduleName = "_winapi" or
      moduleName = "_win32api" or
      moduleName = "_winreg" or
      moduleName = "nt" or
      moduleName.matches("win32%") or
      moduleName = "ntpath"
    )
    or
    // Linux平台相关的模块
    result = "linux2" and
    (moduleName = "posix" or moduleName = "posixpath")
    or
    // 不支持的平台相关的模块
    result = "unsupported" and
    (moduleName = "__pypy__" or moduleName = "ce" or moduleName.matches("riscos%"))
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
predicate isImportAllowedToFail(ImportExpr importExpr) {
  // 存在可用的替代导入表达式
  findAlternativeImport(importExpr).refersTo(_)
  or
  // 导入表达式是特定操作系统相关的，但与当前操作系统不匹配
  getOSSpecificImport(importExpr) != getCurrentOS()
}

/**
 * 表示Python版本测试节点的类
 * 这些节点通常用于检查Python解释器的版本信息
 */
class PythonVersionTest extends ControlFlowNode {
  PythonVersionTest() {
    // 检查节点是否引用了sys模块的版本相关属性
    exists(string attributeName |
      attributeName.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(attributeName))
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
from ImportExpr importExpr
where
  // 导入表达式无法解析为任何模块
  not importExpr.refersTo(_) and 
  // 导入表达式存在于有效的分析上下文中
  exists(Context context | context.appliesTo(importExpr.getAFlowNode())) and 
  // 导入表达式不被允许失败
  not isImportAllowedToFail(importExpr) and 
  // 导入表达式不受版本保护块的控制
  not exists(PythonVersionGuard versionGuard | versionGuard.controls(importExpr.getAFlowNode().getBasicBlock(), _))
// 选择符合条件的导入表达式并生成问题描述
select importExpr, "Unable to resolve import of '" + importExpr.getImportedModuleName() + "'."