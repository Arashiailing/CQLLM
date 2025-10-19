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

// 检查给定导入语句是否导致了模块自导入
predicate selfImportingModule(ImportingStmt importStatement, ModuleValue importedModule) {
  // 验证导入语句的所属模块与被导入模块相同
  importStatement.getEnclosingModule() = importedModule.getScope() and
  // 确定导入语句引用的模块名称，并匹配对应的模块值
  importedModule =
    max(string moduleName, ModuleValue candidateModule |
      moduleName = importStatement.getAnImportedModuleName() and
      candidateModule.importedAs(moduleName)
    |
      candidateModule order by moduleName.length()
    )
}

// 查找所有自导入的模块实例
from ImportingStmt importStatement, ModuleValue importedModule
where selfImportingModule(importStatement, importedModule)
select importStatement, "The module '" + importedModule.getName() + "' imports itself."