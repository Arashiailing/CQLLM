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
predicate is_simple_import(Import imp) { 
  not exists(Attribute attr | imp.contains(attr)) 
}

// 检测重复导入的核心逻辑
predicate double_import(Import firstImport, Import redundantImport, Module importedModule) {
  // 基础条件：两个导入必须不同且都是简单导入
  firstImport != redundantImport and
  is_simple_import(firstImport) and
  is_simple_import(redundantImport) and
  
  // 模块匹配条件：两个导入指向相同模块
  exists(ImportExpr firstExpr, ImportExpr redundantExpr |
    firstExpr.getName() = importedModule.getName() and
    redundantExpr.getName() = importedModule.getName() and
    firstExpr = firstImport.getAName().getValue() and
    redundantExpr = redundantImport.getAName().getValue()
  ) and
  
  // 别名匹配条件：两个导入使用相同别名
  firstImport.getAName().getAsname().(Name).getId() = 
  redundantImport.getAName().getAsname().(Name).getId() and
  
  // 作用域和位置条件
  exists(Module enclosingModule |
    firstImport.getScope() = enclosingModule and
    redundantImport.getEnclosingModule() = enclosingModule and
    (
      // 情况1：重复导入不在顶层作用域
      redundantImport.getScope() != enclosingModule
      or
      // 情况2：首次导入在代码位置上优先于重复导入
      firstImport.getAnEntryNode().dominates(redundantImport.getAnEntryNode())
    )
  )
}

// 查询并报告重复导入问题
from Import firstImport, Import redundantImport, Module importedModule
where double_import(firstImport, redundantImport, importedModule)
select redundantImport,
  "This import of module " + importedModule.getName() + " is redundant, as it was previously imported $@.",
  firstImport, "on line " + firstImport.getLocation().getStartLine().toString()