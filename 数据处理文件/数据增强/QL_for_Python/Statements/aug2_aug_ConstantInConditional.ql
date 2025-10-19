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

// 判断表达式是否被用作条件测试
predicate used_as_condition(Expr conditionalExpr) {
  // 检查表达式是否出现在if语句的条件位置
  exists(If ifStatement | ifStatement.getTest() = conditionalExpr) or
  // 检查表达式是否出现在条件表达式的测试位置
  exists(IfExp ifExpression | ifExpression.getTest() = conditionalExpr)
}

/* Consider specific built-in names as constants if they haven't been redefined. */
// 识别特定内置常量名称，前提是它们未被重新定义
predicate is_effective_constant(Name varNameNode) {
  // 查找未被重新定义的全局内置常量
  exists(GlobalVariable globalVariable | 
    globalVariable = varNameNode.getVariable() and 
    not exists(NameNode defNode | defNode.defines(globalVariable)) |
    globalVariable.getId() = "True" or 
    globalVariable.getId() = "False" or 
    globalVariable.getId() = "NotImplemented"
  )
}

// 检测会导致代码不可达的条件表达式
predicate causes_unreachable_code(Expr conditionalExpr) {
  // 检查if语句中导致分支不可达的条件
  exists(If ifStatement | 
    ifStatement.getTest() = conditionalExpr and 
    (ifStatement.getStmt(0).isUnreachable() or 
     ifStatement.getOrelse(0).isUnreachable())
  )
  or
  // 检查while循环中导致循环体不可达的条件
  exists(While whileStatement | 
    whileStatement.getTest() = conditionalExpr and 
    whileStatement.getStmt(0).isUnreachable()
  )
}

// 查找所有在条件上下文中使用的常量表达式
from Expr conditionalExpr
where
  // 确保表达式在条件上下文中使用
  used_as_condition(conditionalExpr) and
  // 检查是否为常量或等效常量
  (conditionalExpr.isConstant() or is_effective_constant(conditionalExpr)) and
  /* Exclude conditions that make code unreachable (handled by separate query) */
  // 排除导致不可达代码的情况（由其他查询处理）
  not causes_unreachable_code(conditionalExpr)
// 报告检测结果
select conditionalExpr, "Testing a constant will always give the same result."