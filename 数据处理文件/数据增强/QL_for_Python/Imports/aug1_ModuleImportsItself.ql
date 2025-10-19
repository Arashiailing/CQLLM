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
 * 判断一个模块是否导入自身。
 * @param importStmt - 导入语句
 * @param importedModule - 被导入的模块
 * @returns 如果导入语句所在的模块与被导入的模块相同，则返回 true
 */
predicate modules_imports_itself(ImportingStmt importStmt, ModuleValue importedModule) {
  // 检查导入语句所在的封闭模块是否与给定模块的作用域相同
  importStmt.getEnclosingModule() = importedModule.getScope() and
  // 获取导入语句中导入的模块名称，并找到对应的模块值
  importedModule =
    max(string moduleName, ModuleValue candidateModule |
      moduleName = importStmt.getAnImportedModuleName() and
      candidateModule.importedAs(moduleName)
    |
      candidateModule order by moduleName.length()
    )
}

// 查找所有模块导入自身的情况
from ImportingStmt importStmt, ModuleValue importedModule
where modules_imports_itself(importStmt, importedModule)
select importStmt, "The module '" + importedModule.getName() + "' imports itself."