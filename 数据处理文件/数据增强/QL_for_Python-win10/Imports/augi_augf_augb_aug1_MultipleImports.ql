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

// 检查导入语句是否为简单导入形式（即不包含属性访问）
predicate isPlainImport(Import importStmt) { 
  not exists(Attribute attrAccess | importStmt.contains(attrAccess)) 
}

// 确定重复导入：同一模块被多次导入且使用相同别名
predicate identifiesRedundantImport(Import initialImport, Import repeatedImport, Module targetModule) {
  // 基本条件：两个导入语句不同且都是简单导入
  initialImport != repeatedImport and
  isPlainImport(initialImport) and 
  isPlainImport(repeatedImport) and
  
  // 检查两个导入是否引用相同模块
  exists(ImportExpr initialExpr, ImportExpr repeatedExpr |
    initialExpr.getName() = targetModule.getName() and
    repeatedExpr.getName() = targetModule.getName() and
    initialExpr = initialImport.getAName().getValue() and
    repeatedExpr = repeatedImport.getAName().getValue()
  ) and
  
  // 确保别名相同
  initialImport.getAName().getAsname().(Name).getId() = repeatedImport.getAName().getAsname().(Name).getId() and
  
  // 检查作用域和位置关系
  exists(Module enclosingModule |
    initialImport.getScope() = enclosingModule and
    repeatedImport.getEnclosingModule() = enclosingModule and
    (
      /* 重复导入不在顶层作用域 */
      repeatedImport.getScope() != enclosingModule
      or
      /* 初始导入在代码中位置靠前 */
      initialImport.getAnEntryNode().dominates(repeatedImport.getAnEntryNode())
    )
  )
}

// 查找并报告重复导入的情况
from Import initialImport, Import repeatedImport, Module targetModule
where identifiesRedundantImport(initialImport, repeatedImport, targetModule)
select repeatedImport,
  "This import of module " + targetModule.getName() + " is redundant, as it was previously imported $@.",
  initialImport, "on line " + initialImport.getLocation().getStartLine().toString()