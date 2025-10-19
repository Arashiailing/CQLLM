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

// 判断导入语句是否为简单导入（不包含属性访问）
predicate is_simple_import(Import importStmt) { 
  not exists(Attribute attr | importStmt.contains(attr)) 
}

// 检查重复导入情况：同一模块被多次导入且别名相同
predicate duplicate_import(Import firstImport, Import secondImport, Module importedModule) {
  // 确保不是同一个导入语句
  firstImport != secondImport and
  // 两个导入都必须是简单导入
  is_simple_import(firstImport) and 
  is_simple_import(secondImport) and
  
  /* 验证导入的是同一模块 */
  exists(ImportExpr firstExpr, ImportExpr secondExpr |
    firstExpr.getName() = importedModule.getName() and
    secondExpr.getName() = importedModule.getName() and
    firstExpr = firstImport.getAName().getValue() and
    secondExpr = secondImport.getAName().getValue()
  ) and
  
  // 确保别名相同
  firstImport.getAName().getAsname().(Name).getId() = secondImport.getAName().getAsname().(Name).getId() and
  
  // 检查作用域和位置关系
  exists(Module enclosingModule |
    firstImport.getScope() = enclosingModule and
    secondImport.getEnclosingModule() = enclosingModule and
    (
      /* 重复导入不在顶层作用域 */
      secondImport.getScope() != enclosingModule
      or
      /* 原始导入在代码中位置靠前 */
      firstImport.getAnEntryNode().dominates(secondImport.getAnEntryNode())
    )
  )
}

// 查询并报告重复导入情况
from Import firstImport, Import secondImport, Module importedModule
where duplicate_import(firstImport, secondImport, importedModule)
select secondImport,
  "This import of module " + importedModule.getName() + " is redundant, as it was previously imported $@.",
  firstImport, "on line " + firstImport.getLocation().getStartLine().toString()