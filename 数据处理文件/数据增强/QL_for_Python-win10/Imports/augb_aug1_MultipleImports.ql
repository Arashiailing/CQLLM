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

// 验证导入语句是否为简单形式（不包含属性访问）
predicate isSimpleImport(Import importStmt) { 
  not exists(Attribute attr | importStmt.contains(attr)) 
}

// 检测重复导入情况：同一模块被多次导入且使用相同别名
predicate hasDuplicateImport(Import initialImport, Import redundantImport, Module targetModule) {
  // 确保不是同一个导入语句
  initialImport != redundantImport and
  // 两个导入都必须是简单导入
  isSimpleImport(initialImport) and 
  isSimpleImport(redundantImport) and
  
  /* 验证导入的是同一模块 */
  exists(ImportExpr initialExpr, ImportExpr redundantExpr |
    initialExpr.getName() = targetModule.getName() and
    redundantExpr.getName() = targetModule.getName() and
    initialExpr = initialImport.getAName().getValue() and
    redundantExpr = redundantImport.getAName().getValue()
  ) and
  
  // 确保别名相同
  initialImport.getAName().getAsname().(Name).getId() = redundantImport.getAName().getAsname().(Name).getId() and
  
  // 检查作用域和位置关系
  exists(Module containerModule |
    initialImport.getScope() = containerModule and
    redundantImport.getEnclosingModule() = containerModule and
    (
      /* 重复导入不在顶层作用域 */
      redundantImport.getScope() != containerModule
      or
      /* 初始导入在代码中位置靠前 */
      initialImport.getAnEntryNode().dominates(redundantImport.getAnEntryNode())
    )
  )
}

// 查询并报告重复导入情况
from Import initialImport, Import redundantImport, Module targetModule
where hasDuplicateImport(initialImport, redundantImport, targetModule)
select redundantImport,
  "This import of module " + targetModule.getName() + " is redundant, as it was previously imported $@.",
  initialImport, "on line " + initialImport.getLocation().getStartLine().toString()