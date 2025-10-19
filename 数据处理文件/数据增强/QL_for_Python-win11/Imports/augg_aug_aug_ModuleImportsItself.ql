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

// 判断是否存在模块自导入现象的谓词
// 当发现导入语句的目标模块与当前所在模块相同时，判定为自导入
predicate hasSelfImport(ImportingStmt importDeclaration, ModuleValue targetModule) {
  // 确认导入语句所在模块与目标模块的作用域相同
  importDeclaration.getEnclosingModule() = targetModule.getScope() and
  // 通过聚合操作筛选出最匹配的模块值
  // 采用最长名称匹配策略，确保正确处理相对导入情况
  targetModule = 
    max(string moduleName, ModuleValue potentialModule |
      moduleName = importDeclaration.getAnImportedModuleName() and
      potentialModule.importedAs(moduleName)
    |
      potentialModule order by moduleName.length()
    )
}

// 检索所有存在自导入行为的模块实例
from ImportingStmt selfImportStmt, ModuleValue selfReferencedModule
where hasSelfImport(selfImportStmt, selfReferencedModule)
select selfImportStmt, "The module '" + selfReferencedModule.getName() + "' imports itself."