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
 * 查找与给定导入表达式互为替代方案的导入表达式
 * 当两个导入表达式位于条件分支的不同路径中时，它们可能互为替代方案
 */
ImportExpr findAlternativeImportExpression(ImportExpr targetImport) {
  // 检查是否存在别名映射，使得目标导入表达式或其成员模块与结果表达式相关联
  exists(Alias targetAlias, Alias resultAlias |
    (targetAlias.getValue() = targetImport or targetAlias.getValue().(ImportMember).getModule() = targetImport) and
    (resultAlias.getValue() = result or resultAlias.getValue().(ImportMember).getModule() = result) and
    (
      // 检查if语句的两个分支是否分别包含目标导入表达式和结果表达式
      exists(If conditional | conditional.getBody().contains(targetImport) and conditional.getOrelse().contains(result))
      or
      exists(If conditional | conditional.getBody().contains(result) and conditional.getOrelse().contains(targetImport))
      or
      // 检查try语句的主体和异常处理块是否分别包含目标导入表达式和结果表达式
      exists(Try exceptionBlock | exceptionBlock.getBody().contains(targetImport) and exceptionBlock.getAHandler().contains(result))
      or
      exists(Try exceptionBlock | exceptionBlock.getBody().contains(result) and exceptionBlock.getAHandler().contains(targetImport))
    )
  )
}

/**
 * 确定导入表达式是否与特定操作系统相关
 * 返回对应的操作系统名称，如果不匹配任何已知模式则返回空字符串
 */
string determineOSSpecificImport(ImportExpr importExpression) {
  exists(string importedModule | importedModule = importExpression.getImportedModuleName() |
    // Java平台相关的模块
    (importedModule.matches("org.python.%") or importedModule.matches("java.%")) and result = "java"
    or
    // macOS (Darwin)平台相关的模块
    importedModule.matches("Carbon.%") and result = "darwin"
    or
    // Windows平台相关的模块
    result = "win32" and
    (
      importedModule = "_winapi" or
      importedModule = "_win32api" or
      importedModule = "_winreg" or
      importedModule = "nt" or
      importedModule.matches("win32%") or
      importedModule = "ntpath"
    )
    or
    // Linux平台相关的模块
    result = "linux2" and
    (importedModule = "posix" or importedModule = "posixpath")
    or
    // 不支持的平台相关的模块
    result = "unsupported" and
    (importedModule = "__pypy__" or importedModule = "ce" or importedModule.matches("riscos%"))
  )
}

/**
 * 获取当前运行的操作系统平台信息
 * 通过检查sys.platform的值来确定当前操作系统
 */
string getRuntimeOSPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * 判断导入表达式是否被允许失败
 * 如果存在替代导入方案，或者导入表达式是针对特定操作系统但与当前系统不匹配，则允许失败
 */
predicate isImportFailureAcceptable(ImportExpr importExpression) {
  // 存在可用的替代导入表达式
  findAlternativeImportExpression(importExpression).refersTo(_)
  or
  // 导入表达式是特定操作系统相关的，但与当前操作系统不匹配
  determineOSSpecificImport(importExpression) != getRuntimeOSPlatform()
}

/**
 * 表示Python版本测试节点的类
 * 这些节点通常用于检查Python解释器的版本信息
 */
class PythonVersionCheckNode extends ControlFlowNode {
  PythonVersionCheckNode() {
    // 检查节点是否引用了sys模块的版本相关属性
    exists(string versionAttribute |
      versionAttribute.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionAttribute))
    )
  }

  override string toString() { result = "VersionTest" }
}

/**
 * 表示Python版本保护块的类
 * 这些代码块根据Python版本条件控制代码执行路径
 */
class PythonVersionConditionalBlock extends ConditionBlock {
  PythonVersionConditionalBlock() { 
    // 检查条件块的最后一个节点是否是版本测试节点
    this.getLastNode() instanceof PythonVersionCheckNode 
  }
}

// 主查询：查找无法解析且不应失败的导入表达式
from ImportExpr unresolvedImport
where
  // 导入表达式无法解析为任何模块
  not unresolvedImport.refersTo(_) and 
  // 导入表达式存在于有效的分析上下文中
  exists(Context analysisContext | analysisContext.appliesTo(unresolvedImport.getAFlowNode())) and 
  // 导入表达式不被允许失败
  not isImportFailureAcceptable(unresolvedImport) and 
  // 导入表达式不受版本保护块的控制
  not exists(PythonVersionConditionalBlock versionGuard | versionGuard.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _))
// 选择符合条件的导入表达式并生成问题描述
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."