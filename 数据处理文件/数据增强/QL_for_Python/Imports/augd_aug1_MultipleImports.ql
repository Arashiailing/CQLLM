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

// 判断导入语句是否为简单导入（即不包含属性访问的导入形式）
predicate is_simple_import(Import importDeclaration) { 
  // 检查导入语句中不包含任何属性访问节点
  not exists(Attribute attributeAccess | importDeclaration.contains(attributeAccess)) 
}

// 检测重复导入情况：同一模块被多次导入并且使用相同的别名
predicate duplicate_import(Import initialImport, Import repeatedImport, Module targetModule) {
  // 确保不是同一个导入语句
  initialImport != repeatedImport and
  // 两个导入都必须是简单导入（不带属性访问）
  is_simple_import(initialImport) and 
  is_simple_import(repeatedImport) and
  
  /* 验证两个导入语句引用的是同一模块 */
  exists(ImportExpr initialExpr, ImportExpr repeatedExpr |
    // 检查导入表达式名称与目标模块名称匹配
    initialExpr.getName() = targetModule.getName() and
    repeatedExpr.getName() = targetModule.getName() and
    // 确保导入表达式分别属于对应的导入语句
    initialExpr = initialImport.getAName().getValue() and
    repeatedExpr = repeatedImport.getAName().getValue()
  ) and
  
  // 确保两个导入使用的别名相同
  initialImport.getAName().getAsname().(Name).getId() = repeatedImport.getAName().getAsname().(Name).getId() and
  
  // 检查作用域和位置关系
  exists(Module parentModule |
    initialImport.getScope() = parentModule and
    repeatedImport.getEnclosingModule() = parentModule and
    (
      /* 情况1：重复导入不在顶层作用域 */
      repeatedImport.getScope() != parentModule
      or
      /* 情况2：原始导入在代码中位置靠前（支配重复导入） */
      initialImport.getAnEntryNode().dominates(repeatedImport.getAnEntryNode())
    )
  )
}

// 查询并报告重复导入情况
from Import initialImport, Import repeatedImport, Module targetModule
where duplicate_import(initialImport, repeatedImport, targetModule)
select repeatedImport,
  "This import of module " + targetModule.getName() + " is redundant, as it was previously imported $@.",
  initialImport, "on line " + initialImport.getLocation().getStartLine().toString()