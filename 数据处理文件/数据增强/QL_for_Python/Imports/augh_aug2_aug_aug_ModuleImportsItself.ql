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

// 检测模块自导入行为的谓词
// 当导入语句的上下文模块与被导入的模块引用相同时，判定为自导入
predicate selfImportDetected(ImportingStmt importStmt, ModuleValue importedModule) {
  // 使用聚合操作筛选最匹配的模块引用
  // 优先选择名称最长的匹配项，以正确处理相对导入场景
  importedModule = 
    max(string importedName, ModuleValue candidateModule |
      importedName = importStmt.getAnImportedModuleName() and
      candidateModule.importedAs(importedName)
    |
      candidateModule order by importedName.length()
    ) and
  // 验证导入语句所在的模块与被导入模块的作用域一致
  importStmt.getEnclosingModule() = importedModule.getScope()
}

// 查询所有自导入模块的实例
from ImportingStmt importStmt, ModuleValue selfImportedModule
where selfImportDetected(importStmt, selfImportedModule)
select importStmt, "The module '" + selfImportedModule.getName() + "' imports itself."