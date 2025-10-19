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

import python

from Expr parenthesizedExpr, Location exprLocation, string stmtType, string exprRole
where
  // 确保表达式被括号包围且不是元组
  parenthesizedExpr.isParenthesized() and
  not parenthesizedExpr instanceof Tuple and
  
  // 验证表达式位于同一行内
  exprLocation = parenthesizedExpr.getLocation() and
  exprLocation.getStartLine() = exprLocation.getEndLine() and
  
  // 排除需要括号的表达式类型
  not parenthesizedExpr instanceof Yield and
  not parenthesizedExpr instanceof YieldFrom and
  not parenthesizedExpr instanceof GeneratorExp and
  
  // 检查表达式是否在特定语句中使用
  (
    // 处理if语句的条件表达式
    exists(If ifStmt | 
      ifStmt.getTest() = parenthesizedExpr and 
      stmtType = "if" and 
      exprRole = "condition"
    )
    
    or
    
    // 处理while语句的条件表达式
    exists(While whileStmt | 
      whileStmt.getTest() = parenthesizedExpr and 
      stmtType = "while" and 
      exprRole = "condition"
    )
    
    or
    
    // 处理return语句的返回值
    exists(Return returnStmt | 
      returnStmt.getValue() = parenthesizedExpr and 
      stmtType = "return" and 
      exprRole = "value"
    )
    
    or
    
    // 处理没有消息的assert语句的测试部分
    exists(Assert assertStmt | 
      assertStmt.getTest() = parenthesizedExpr and 
      not exists(assertStmt.getMsg()) and
      stmtType = "assert" and
      exprRole = "test"
    )
  )

// 选择表达式并生成描述信息
select parenthesizedExpr, "Parenthesized " + exprRole + " in '" + stmtType + "' statement."