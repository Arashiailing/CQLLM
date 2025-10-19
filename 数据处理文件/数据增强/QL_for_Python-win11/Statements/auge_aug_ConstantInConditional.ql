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

// 判断表达式是否在条件上下文中使用
predicate usedAsCondition(Expr conditionalExpression) {
  // 检查表达式是否作为if语句的测试条件
  exists(If ifStatement | ifStatement.getTest() = conditionalExpression) or
  // 检查表达式是否作为条件表达式的测试部分
  exists(IfExp ifExp | ifExp.getTest() = conditionalExpression)
}

/* Consider specific unmodified built-in names as constants */
// 识别未被修改的内置常量名称
predicate effective_constant(Name nameIdentifier) {
  // 查找未被重新定义的全局内置变量
  exists(GlobalVariable globalVariable | 
    globalVariable = nameIdentifier.getVariable() and 
    not exists(NameNode definingNode | definingNode.defines(globalVariable)) |
    globalVariable.getId() = "True" or 
    globalVariable.getId() = "False" or 
    globalVariable.getId() = "NotImplemented"
  )
}

// 检测导致代码不可达的条件表达式
predicate createsUnreachableCode(Expr conditionalExpression) {
  // 检查if语句中导致分支不可达的条件
  exists(If ifStatement | 
    ifStatement.getTest() = conditionalExpression and 
    (ifStatement.getStmt(0).isUnreachable() or 
     ifStatement.getOrelse(0).isUnreachable())
  )
  or
  // 检查while循环中导致循环体不可达的条件
  exists(While whileStatement | 
    whileStatement.getTest() = conditionalExpression and 
    whileStatement.getStmt(0).isUnreachable()
  )
}

// 查找在条件上下文中使用的常量表达式
from Expr conditionalExpression
where
  // 确保表达式在条件上下文中使用
  usedAsCondition(conditionalExpression) and
  // 检查表达式是否为常量或等效常量
  (conditionalExpression.isConstant() or effective_constant(conditionalExpression)) and
  /* Exclude conditions that make code unreachable (handled by separate query) */
  // 排除导致不可达代码的情况（由其他查询处理）
  not createsUnreachableCode(conditionalExpression)
// 报告检测结果
select conditionalExpression, "Testing a constant will always give the same result."