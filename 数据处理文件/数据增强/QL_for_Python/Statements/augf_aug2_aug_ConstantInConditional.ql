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

// 确定表达式是否在条件判断中使用
predicate used_as_condition(Expr conditionExpr) {
  // 表达式是否作为if语句的条件
  exists(If ifNode | ifNode.getTest() = conditionExpr) or
  // 表达式是否作为条件表达式的测试部分
  exists(IfExp ifExpNode | ifExpNode.getTest() = conditionExpr)
}

/* 识别未被重新定义的特定内置常量名称 */
predicate is_effective_constant(Name nameNode) {
  // 查找未被重新定义的全局内置变量
  exists(GlobalVariable globalVar | 
    globalVar = nameNode.getVariable() and 
    not exists(NameNode defNode | defNode.defines(globalVar)) |
    globalVar.getId() = "True" or 
    globalVar.getId() = "False" or 
    globalVar.getId() = "NotImplemented"
  )
}

// 识别导致代码不可达的条件表达式
predicate causes_unreachable_code(Expr conditionExpr) {
  // 检查if语句中导致其分支不可达的条件
  exists(If ifNode | 
    ifNode.getTest() = conditionExpr and 
    (ifNode.getStmt(0).isUnreachable() or 
     ifNode.getOrelse(0).isUnreachable())
  )
  or
  // 检查while循环中导致循环体不可达的条件
  exists(While whileNode | 
    whileNode.getTest() = conditionExpr and 
    whileNode.getStmt(0).isUnreachable()
  )
}

// 查找所有在条件上下文中使用的常量表达式
from Expr conditionExpr
where
  // 表达式必须在条件上下文中使用
  used_as_condition(conditionExpr) and
  // 表达式是常量或等效常量
  (conditionExpr.isConstant() or is_effective_constant(conditionExpr)) and
  /* 排除导致不可达代码的情况（由其他查询专门处理） */
  not causes_unreachable_code(conditionExpr)
// 报告检测结果
select conditionExpr, "Testing a constant will always give the same result."