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

// 判断表达式是否在条件语句或条件表达式中作为测试条件使用
predicate is_condition(Expr condExpr) {
  // 检查表达式是否作为if语句的测试条件
  exists(If ifNode | ifNode.getTest() = condExpr) or
  // 检查表达式是否作为条件表达式的测试部分
  exists(IfExp ifExprNode | ifExprNode.getTest() = condExpr)
}

/* Treat certain unmodified builtins as constants as well. */
// 识别未被重新定义的特定内置常量名称
predicate effective_constant(Name constName) {
  exists(GlobalVariable globalConstant | 
    globalConstant = constName.getVariable() and 
    // 确保该全局变量未被重新定义
    not exists(NameNode definitionNode | definitionNode.defines(globalConstant)) |
    // 检查是否为预定义的布尔常量或特殊常量
    globalConstant.getId() = "True" or 
    globalConstant.getId() = "False" or 
    globalConstant.getId() = "NotImplemented"
  )
}

// 检测导致代码不可达的条件表达式
predicate test_makes_code_unreachable(Expr condExpr) {
  // 检查if语句中导致分支不可达的条件
  exists(If ifNode | 
    ifNode.getTest() = condExpr and 
    (ifNode.getStmt(0).isUnreachable() or 
     ifNode.getOrelse(0).isUnreachable())
  )
  or
  // 检查while循环中导致循环体不可达的条件
  exists(While whileNode | 
    whileNode.getTest() = condExpr and 
    whileNode.getStmt(0).isUnreachable()
  )
}

// 查找在条件上下文中使用的常量表达式
from Expr condExpr
where
  // 确保表达式在条件上下文中使用
  is_condition(condExpr) and
  // 检查是否为常量或等效常量
  (condExpr.isConstant() or effective_constant(condExpr)) and
  /* Exclude conditions that make code unreachable (handled by separate query) */
  // 排除导致不可达代码的情况（由其他查询处理）
  not test_makes_code_unreachable(condExpr)
// 报告检测结果
select condExpr, "Testing a constant will always give the same result."