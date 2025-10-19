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

// 定义谓词用于检测模块自导入现象
// 当一个模块通过导入语句引用自身时，触发此谓词
predicate hasSelfImport(ImportingStmt importStmt, ModuleValue importedModule) {
  // 验证导入语句所在的模块与被导入模块的作用域一致
  importStmt.getEnclosingModule() = importedModule.getScope() and
  // 使用聚合函数找出最精确匹配的模块引用
  // 优先选择名称长度最大的模块，以准确处理相对导入路径
  importedModule = 
    max(string importName, ModuleValue candidateModule |
      importName = importStmt.getAnImportedModuleName() and
      candidateModule.importedAs(importName)
    |
      candidateModule order by importName.length()
    )
}

// 查找所有存在自导入行为的模块实例
from ImportingStmt importStmt, ModuleValue selfImportedModule
where hasSelfImport(importStmt, selfImportedModule)
select importStmt, "The module '" + selfImportedModule.getName() + "' imports itself."