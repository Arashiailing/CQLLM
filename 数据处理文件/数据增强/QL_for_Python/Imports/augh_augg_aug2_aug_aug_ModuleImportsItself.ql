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

// 谓词用于识别模块自引用行为
// 当模块通过导入语句直接引用自身时，此谓词成立
predicate selfImportExists(ImportingStmt importDeclaration, ModuleValue targetModule) {
  // 验证导入语句所属模块与目标模块的作用域相同
  importDeclaration.getEnclosingModule() = targetModule.getScope() and
  // 使用聚合函数确定最精确的模块匹配
  // 优先选择名称长度最大的模块，以正确处理相对导入路径
  targetModule = 
    max(string importName, ModuleValue candidateModule |
      importName = importDeclaration.getAnImportedModuleName() and
      candidateModule.importedAs(importName)
    |
      candidateModule order by importName.length()
    )
}

// 检索所有存在自导入行为的模块实例
from ImportingStmt importDeclaration, ModuleValue selfReferencedModule
where selfImportExists(importDeclaration, selfReferencedModule)
select importDeclaration, "The module '" + selfReferencedModule.getName() + "' imports itself."