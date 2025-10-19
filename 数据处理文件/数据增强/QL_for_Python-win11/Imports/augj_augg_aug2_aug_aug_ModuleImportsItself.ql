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

// 谓词定义：识别模块自导入行为
// 当模块中的导入语句引用了该模块自身时，此谓词返回 true
predicate hasSelfImport(ImportingStmt importDeclaration, ModuleValue targetModule) {
  // 确保导入语句所在的模块与被导入模块的作用域相同
  importDeclaration.getEnclosingModule() = targetModule.getScope() and
  // 通过聚合函数找出最精确匹配的模块引用
  exists(string moduleName |
    moduleName = importDeclaration.getAnImportedModuleName() and
    targetModule.importedAs(moduleName) and
    // 确保选择的是名称长度最长的模块，以正确处理相对导入
    not exists(ModuleValue otherModule, string otherModuleName |
      otherModuleName = importDeclaration.getAnImportedModuleName() and
      otherModule.importedAs(otherModuleName) and
      otherModuleName.length() > moduleName.length()
    )
  )
}

// 主查询：识别所有自导入的模块
from ImportingStmt importDeclaration, ModuleValue selfReferencedModule
where hasSelfImport(importDeclaration, selfReferencedModule)
select importDeclaration, "The module '" + selfReferencedModule.getName() + "' imports itself."