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

from Expr parenthesizedExpression, Location expressionLocation, string statementType, string expressionRole  // 从表达式、位置、语句类型和表达式角色中选择数据
where
  // 验证表达式被括号包围且不是元组
  parenthesizedExpression.isParenthesized() and
  not parenthesizedExpression instanceof Tuple and
  
  // 确保表达式位于同一行内
  expressionLocation = parenthesizedExpression.getLocation() and
  expressionLocation.getStartLine() = expressionLocation.getEndLine() and
  
  // 排除需要括号的表达式类型
  not parenthesizedExpression instanceof Yield and
  not parenthesizedExpression instanceof YieldFrom and
  not parenthesizedExpression instanceof GeneratorExp and
  
  // 检查表达式是否在特定语句中使用
  (
    // 处理if语句的条件表达式
    exists(If ifStatement | 
      ifStatement.getTest() = parenthesizedExpression and 
      statementType = "if" and 
      expressionRole = "condition"
    )
    
    or
    
    // 处理while语句的条件表达式
    exists(While whileStatement | 
      whileStatement.getTest() = parenthesizedExpression and 
      statementType = "while" and 
      expressionRole = "condition"
    )
    
    or
    
    // 处理return语句的返回值
    exists(Return returnStatement | 
      returnStatement.getValue() = parenthesizedExpression and 
      statementType = "return" and 
      expressionRole = "value"
    )
    
    or
    
    // 处理没有消息的assert语句的测试部分
    exists(Assert assertStatement | 
      assertStatement.getTest() = parenthesizedExpression and 
      not exists(assertStatement.getMsg()) and
      statementType = "assert" and
      expressionRole = "test"
    )
  )

// 选择表达式并生成描述信息
select parenthesizedExpression, "Parenthesized " + expressionRole + " in '" + statementType + "' statement."