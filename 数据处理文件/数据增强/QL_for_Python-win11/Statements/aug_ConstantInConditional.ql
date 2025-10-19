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

// 判断表达式是否作为条件测试使用
predicate is_condition(Expr conditionExpr) {
  // 检查表达式是否出现在if语句或条件表达式的测试位置
  exists(If ifStmt | ifStmt.getTest() = conditionExpr) or
  exists(IfExp ifExp | ifExp.getTest() = conditionExpr)
}

/* Treat certain unmodified builtins as constants as well. */
// 识别特定内置常量名称
predicate effective_constant(Name nameNode) {
  // 查找未被重新定义的全局内置常量
  exists(GlobalVariable globalVar | 
    globalVar = nameNode.getVariable() and 
    not exists(NameNode defNode | defNode.defines(globalVar)) |
    globalVar.getId() = "True" or 
    globalVar.getId() = "False" or 
    globalVar.getId() = "NotImplemented"
  )
}

// 检测导致不可达代码的条件
predicate test_makes_code_unreachable(Expr conditionExpr) {
  // 检查if语句中导致分支不可达的条件
  exists(If ifStmt | 
    ifStmt.getTest() = conditionExpr and 
    (ifStmt.getStmt(0).isUnreachable() or 
     ifStmt.getOrelse(0).isUnreachable())
  )
  or
  // 检查while循环中导致循环体不可达的条件
  exists(While whileLoop | 
    whileLoop.getTest() = conditionExpr and 
    whileLoop.getStmt(0).isUnreachable()
  )
}

// 查找所有作为条件使用的常量表达式
from Expr conditionExpr
where
  // 确保表达式在条件上下文中使用
  is_condition(conditionExpr) and
  // 检查是否为常量或等效常量
  (conditionExpr.isConstant() or effective_constant(conditionExpr)) and
  /* Exclude conditions that make code unreachable (handled by separate query) */
  // 排除导致不可达代码的情况（由其他查询处理）
  not test_makes_code_unreachable(conditionExpr)
// 报告检测结果
select conditionExpr, "Testing a constant will always give the same result."