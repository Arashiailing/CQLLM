/**
 * @name C-style condition
 * @description Identifies redundant parentheses around expressions in control flow statements.
 *              Such parentheses are unnecessary in Python and reduce code readability.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/c-style-parentheses
 */

import python  // 导入Python语言库，用于分析Python代码

from Expr parenthesizedExpr, Location exprLocation, string statementType, string exprRole  // 从表达式、位置、语句类型和表达式角色中选择数据
where
  // 检查表达式是否被括号包围且不是元组
  parenthesizedExpr.isParenthesized() and
  not parenthesizedExpr instanceof Tuple and
  
  // 检查表达式是否在特定语句中使用
  (
    // 如果表达式是if语句的条件
    exists(If ifStmt | ifStmt.getTest() = parenthesizedExpr) and 
    statementType = "if" and 
    exprRole = "condition"
    
    or
    
    // 如果表达式是while语句的条件
    exists(While whileStmt | whileStmt.getTest() = parenthesizedExpr) and 
    statementType = "while" and 
    exprRole = "condition"
    
    or
    
    // 如果表达式是return语句的值
    exists(Return returnStmt | returnStmt.getValue() = parenthesizedExpr) and 
    statementType = "return" and 
    exprRole = "value"
    
    or
    
    // 如果表达式是assert语句的测试部分且没有消息
    exists(Assert assertStmt | 
      assertStmt.getTest() = parenthesizedExpr and 
      not exists(assertStmt.getMsg())
    ) and
    statementType = "assert" and
    exprRole = "test"
  ) and
  
  // 排除需要括号的表达式类型
  not parenthesizedExpr instanceof Yield and
  not parenthesizedExpr instanceof YieldFrom and
  not parenthesizedExpr instanceof GeneratorExp and
  
  // 获取表达式位置并确保在同一行内
  exprLocation = parenthesizedExpr.getLocation() and
  exprLocation.getStartLine() = exprLocation.getEndLine()

// 选择表达式并生成描述信息
select parenthesizedExpr, "Parenthesized " + exprRole + " in '" + statementType + "' statement."