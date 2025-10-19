/**
 * @name Module imports itself
 * @description A module imports itself
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/import-own-module
 */

import python

/**
 * 检测模块自导入行为
 * @param impStmt - 导入语句
 * @param targetMod - 目标模块
 * @returns 当导入语句所在模块与目标模块作用域一致时返回true
 */
predicate modules_imports_itself(ImportingStmt impStmt, ModuleValue targetMod) {
  // 确保导入语句所属模块与目标模块作用域相同
  impStmt.getEnclosingModule() = targetMod.getScope() and
  // 从导入语句解析模块名并匹配对应模块值，优先选择最短名称的模块
  targetMod =
    max(string modName, ModuleValue modCandidate |
      modName = impStmt.getAnImportedModuleName() and
      modCandidate.importedAs(modName)
    |
      modCandidate order by modName.length()
    )
}

// 定位所有自导入模块场景
from ImportingStmt impStmt, ModuleValue targetMod
where modules_imports_itself(impStmt, targetMod)
select impStmt, "The module '" + targetMod.getName() + "' imports itself."