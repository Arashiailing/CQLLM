/**
 * @name Unresolved import
 * @description An unresolved import may result in reduced coverage and accuracy of analysis.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

// 导入Python库
import python

/**
 * 查找与给定导入表达式存在替代关系的导入表达式。
 * 替代关系通常出现在条件语句中，当两个导入表达式分别位于不同分支时，
 * 它们可能作为同一功能的不同实现方案。
 */
ImportExpr findAlternativeImport(ImportExpr importExpr) {
  // 检查是否存在别名映射关系，使得当前导入表达式与结果表达式构成替代关系
  exists(Alias currentAlias, Alias alternativeAlias |
    // 当前别名映射到原始导入表达式或其成员模块
    (currentAlias.getValue() = importExpr or currentAlias.getValue().(ImportMember).getModule() = importExpr) and
    // 替代别名映射到结果表达式或其成员模块
    (alternativeAlias.getValue() = result or alternativeAlias.getValue().(ImportMember).getModule() = result) and
    (
      // 检查if语句中的替代关系：两个导入表达式分别位于if和else分支
      exists(If conditionalBlock | 
        conditionalBlock.getBody().contains(importExpr) and conditionalBlock.getOrelse().contains(result)
      )
      or
      exists(If conditionalBlock | 
        conditionalBlock.getBody().contains(result) and conditionalBlock.getOrelse().contains(importExpr)
      )
      or
      // 检查try-except语句中的替代关系：一个在try块，一个在except块
      exists(Try exceptionHandling | 
        exceptionHandling.getBody().contains(importExpr) and exceptionHandling.getAHandler().contains(result)
      )
      or
      exists(Try exceptionHandling | 
        exceptionHandling.getBody().contains(result) and exceptionHandling.getAHandler().contains(importExpr)
      )
    )
  )
}

/**
 * 判断导入表达式是否与特定操作系统相关。
 * 返回导入表达式对应的操作系统名称，用于检测平台特定导入。
 */
string determineOSSpecificImport(ImportExpr importExpr) {
  // 检查导入模块名称是否匹配特定操作系统的模式
  exists(string moduleName | moduleName = importExpr.getImportedModuleName() |
    // Java平台相关导入
    (moduleName.matches("org.python.%") or moduleName.matches("java.%")) and result = "java"
    or
    // macOS平台相关导入
    moduleName.matches("Carbon.%") and result = "darwin"
    or
    // Windows平台相关导入
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
    // Linux平台相关导入
    result = "linux2" and
    (moduleName = "posix" or moduleName = "posixpath")
    or
    // 不受支持的平台相关导入
    result = "unsupported" and
    (moduleName = "__pypy__" or moduleName = "ce" or moduleName.matches("riscos%"))
  )
}

// 获取当前运行的操作系统平台信息
string getCurrentPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * 判断导入表达式是否可以接受失败。
 * 如果存在替代导入或导入是针对其他操作系统的，则导入失败是可接受的。
 */
predicate isImportFailureAcceptable(ImportExpr importExpr) {
  // 存在可解析的替代导入
  findAlternativeImport(importExpr).refersTo(_)
  or
  // 导入是针对其他操作系统的
  determineOSSpecificImport(importExpr) != getCurrentPlatform()
}

/**
 * 表示版本测试节点的类，用于检测Python解释器版本相关的条件判断。
 */
class VersionTestNode extends ControlFlowNode {
  VersionTestNode() {
    exists(string versionAttribute |
      versionAttribute.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionAttribute))
    )
  }

  override string toString() { result = "VersionTest" }
}

/**
 * 表示版本保护块的类，用于标识基于Python解释器版本的条件保护代码块。
 */
class VersionProtectionBlock extends ConditionBlock {
  VersionProtectionBlock() { this.getLastNode() instanceof VersionTestNode }
}

// 查询无法解析且不可接受的导入表达式
from ImportExpr importExpr
where
  // 导入表达式无法解析
  not importExpr.refersTo(_) and 
  // 存在适用的分析上下文
  exists(Context analysisContext | analysisContext.appliesTo(importExpr.getAFlowNode())) and 
  // 导入失败是不可接受的
  not isImportFailureAcceptable(importExpr) and 
  // 不存在版本保护块控制该导入
  not exists(VersionProtectionBlock versionBlock | 
    versionBlock.controls(importExpr.getAFlowNode().getBasicBlock(), _)
  )
// 选择无法解析的导入表达式并输出提示信息
select importExpr, "Unable to resolve import of '" + importExpr.getImportedModuleName() + "'."