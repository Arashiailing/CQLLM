/**
 * @name Module is imported more than once
 * @description Importing a module a second time has no effect and impairs readability
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// 判断导入语句是否为简单形式（不包含属性访问）
predicate isPlainImport(Import importDeclaration) { 
  not exists(Attribute attributeAccess | importDeclaration.contains(attributeAccess)) 
}

// 识别重复导入情况：同一模块被多次导入且使用相同别名
predicate identifiesRedundantImport(Import primaryImport, Import duplicateImport, Module importedModule) {
  // 确保不是同一个导入语句
  primaryImport != duplicateImport and
  // 两个导入都必须是简单导入
  isPlainImport(primaryImport) and 
  isPlainImport(duplicateImport) and
  
  /* 验证导入的是同一模块 */
  exists(ImportExpr primaryExpr, ImportExpr duplicateExpr |
    primaryExpr.getName() = importedModule.getName() and
    duplicateExpr.getName() = importedModule.getName() and
    primaryExpr = primaryImport.getAName().getValue() and
    duplicateExpr = duplicateImport.getAName().getValue()
  ) and
  
  // 确保别名相同
  primaryImport.getAName().getAsname().(Name).getId() = duplicateImport.getAName().getAsname().(Name).getId() and
  
  // 检查作用域和位置关系
  exists(Module parentModule |
    primaryImport.getScope() = parentModule and
    duplicateImport.getEnclosingModule() = parentModule and
    (
      /* 重复导入不在顶层作用域 */
      duplicateImport.getScope() != parentModule
      or
      /* 初始导入在代码中位置靠前 */
      primaryImport.getAnEntryNode().dominates(duplicateImport.getAnEntryNode())
    )
  )
}

// 查询并报告重复导入情况
from Import primaryImport, Import duplicateImport, Module importedModule
where identifiesRedundantImport(primaryImport, duplicateImport, importedModule)
select duplicateImport,
  "This import of module " + importedModule.getName() + " is redundant, as it was previously imported $@.",
  primaryImport, "on line " + primaryImport.getLocation().getStartLine().toString()