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

// 判断模块是否存在自导入行为的谓词
// 当导入语句的上下文模块与被导入的模块引用相同时，判定为自导入
predicate selfImportDetected(ImportingStmt importDeclaration, ModuleValue moduleReference) {
  // 确认导入语句所在的模块与被导入模块的作用域相同
  importDeclaration.getEnclosingModule() = moduleReference.getScope() and
  // 通过聚合操作筛选出最匹配的模块引用
  // 优先选择名称最长的匹配项，以正确处理相对导入情况
  moduleReference = 
    max(string moduleName, ModuleValue potentialModule |
      moduleName = importDeclaration.getAnImportedModuleName() and
      potentialModule.importedAs(moduleName)
    |
      potentialModule order by moduleName.length()
    )
}

// 检索所有自导入模块的实例
from ImportingStmt importDeclaration, ModuleValue targetModule
where selfImportDetected(importDeclaration, targetModule)
select importDeclaration, "The module '" + targetModule.getName() + "' imports itself."