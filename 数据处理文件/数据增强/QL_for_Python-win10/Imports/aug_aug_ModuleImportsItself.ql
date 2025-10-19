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

// 检测模块自导入行为的谓词函数
// 当导入语句所属模块与被导入模块相同时触发
predicate hasSelfImport(ImportingStmt impStmt, ModuleValue modVal) {
  // 验证导入语句所属模块与被导入模块的作用域一致
  impStmt.getEnclosingModule() = modVal.getScope() and
  // 通过聚合操作确定最匹配的模块值
  // 优先选择最长匹配名称的模块以正确处理相对导入
  modVal = 
    max(string importedName, ModuleValue candidate |
      importedName = impStmt.getAnImportedModuleName() and
      candidate.importedAs(importedName)
    |
      candidate order by importedName.length()
    )
}

// 查询所有自导入模块实例
from ImportingStmt importStmt, ModuleValue importedModule
where hasSelfImport(importStmt, importedModule)
select importStmt, "The module '" + importedModule.getName() + "' imports itself."