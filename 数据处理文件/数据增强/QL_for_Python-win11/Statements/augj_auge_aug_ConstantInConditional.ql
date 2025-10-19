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

// 确定表达式是否作为条件判断使用
predicate usedAsCondition(Expr conditionExpr) {
  // 验证表达式是否作为if语句的条件部分
  exists(If ifNode | ifNode.getTest() = conditionExpr) or
  // 验证表达式是否作为条件表达式（三元运算符）的测试部分
  exists(IfExp conditionalExpr | conditionalExpr.getTest() = conditionExpr)
}

/* Check for unmodified built-in names that should be treated as constants */
// 识别未被重新赋值的内置常量名称
predicate effective_constant(Name constantName) {
  // 查找未被重新定义的全局内置变量
  exists(GlobalVariable globalConstant | 
    globalConstant = constantName.getVariable() and 
    not exists(NameNode definitionNode | definitionNode.defines(globalConstant)) |
    globalConstant.getId() = "True" or 
    globalConstant.getId() = "False" or 
    globalConstant.getId() = "NotImplemented"
  )
}

// 检测因条件恒定而导致代码不可达的表达式
predicate createsUnreachableCode(Expr conditionExpr) {
  // 检查if语句中因条件恒定而导致分支不可达的情况
  exists(If ifNode | 
    ifNode.getTest() = conditionExpr and 
    (ifNode.getStmt(0).isUnreachable() or 
     ifNode.getOrelse(0).isUnreachable())
  )
  or
  // 检查while循环中因条件恒定而导致循环体不可达的情况
  exists(While whileNode | 
    whileNode.getTest() = conditionExpr and 
    whileNode.getStmt(0).isUnreachable()
  )
}

// 主查询：查找在条件上下文中使用的常量表达式
from Expr conditionExpr
where
  // 确认表达式被用作条件判断
  usedAsCondition(conditionExpr) and
  // 检查表达式是否为常量或等效于常量
  (conditionExpr.isConstant() or effective_constant(conditionExpr)) and
  /* Exclude conditions that make code unreachable (handled by separate query) */
  // 排除导致代码不可达的条件（这些情况由其他查询处理）
  not createsUnreachableCode(conditionExpr)
// 输出检测结果
select conditionExpr, "Testing a constant will always give the same result."