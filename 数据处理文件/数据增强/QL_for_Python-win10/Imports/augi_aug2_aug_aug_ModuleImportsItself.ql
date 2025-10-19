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
  // 确保导入语句所在的模块与被导入模块的作用域相同
  importStmt.getEnclosingModule() = importedModule.getScope() and
  // 通过聚合操作找出最匹配的模块引用
  // 优先选择名称最长的匹配项，以正确处理相对导入情况
  importedModule = 
    max(string moduleName, ModuleValue candidateModule |
      moduleName = importStmt.getAnImportedModuleName() and
      candidateModule.importedAs(moduleName)
    |
      candidateModule order by moduleName.length()
    )
}

// 查找所有自导入模块的实例
from ImportingStmt importStmt, ModuleValue selfImportedModule
where selfImportDetected(importStmt, selfImportedModule)
select importStmt, "The module '" + selfImportedModule.getName() + "' imports itself."