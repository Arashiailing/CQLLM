/**
 * @name Constant in conditional expression or statement
 * @description The conditional is always true or always false
 * @kind problem
 * @tags maintainability
 *       useless-code
 *       external/cwe/cwe-561
 *       external/cwe/cwe-570
 *       external/cwe/cwe-571
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/constant-conditional-expression
 */

import python

// 判断表达式是否作为条件语句中的测试条件
predicate is_condition(Expr conditionExpr) {
  // 检查是否存在If语句或IfExp表达式使用该表达式作为测试条件
  exists(If ifStmt | ifStmt.getTest() = conditionExpr) or
  exists(IfExp ifExp | ifExp.getTest() = conditionExpr)
}

/* 将某些未修改的内置函数也视为常量 */
// 判断名称是否为特定的内置常量
predicate effective_constant(Name conditionExpr) {
  // 检查是否存在未被重新定义的全局变量，且变量名为特定内置常量
  exists(GlobalVariable globalVar | 
    globalVar = conditionExpr.getVariable() and 
    not exists(NameNode nameNode | nameNode.defines(globalVar)) |
    globalVar.getId() = "True" or 
    globalVar.getId() = "False" or 
    globalVar.getId() = "NotImplemented"
  )
}

// 判断测试条件是否导致代码不可达
predicate test_makes_code_unreachable(Expr conditionExpr) {
  // 检查If语句的分支是否不可达，或While循环体是否不可达
  exists(If ifStmt | ifStmt.getTest() = conditionExpr | 
    ifStmt.getStmt(0).isUnreachable() or 
    ifStmt.getOrelse(0).isUnreachable()
  )
  or
  exists(While whileLoop | 
    whileLoop.getTest() = conditionExpr and 
    whileLoop.getStmt(0).isUnreachable()
  )
}

// 从所有表达式中筛选出满足条件的表达式
from Expr conditionExpr
where
  // 确保表达式是条件语句中的测试条件
  is_condition(conditionExpr) and
  // 确保表达式是常量或特定的内置常量
  (conditionExpr.isConstant() or effective_constant(conditionExpr)) and
  /* 忽略测试条件导致代码不可达的情况，因为这种情况由不同的查询处理 */
  not test_makes_code_unreachable(conditionExpr)
// 选择符合条件的表达式并报告问题
select conditionExpr, "Testing a constant will always give the same result."