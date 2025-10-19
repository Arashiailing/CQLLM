/**
 * @name C-style condition
 * @description Identifies unnecessary parentheses around conditions in 'if', 'while', 'return', 
 *              and 'assert' statements, which reduce code readability.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/c-style-parentheses
 */

import python  // 导入Python语言库，用于分析Python代码

from Expr parenthesizedExpr, Location exprLocation, string stmtType, string exprRole  // 从表达式、位置、语句类型和表达式角色中选择数据
where
  // 检查表达式是否被括号包围，且不是元组
  parenthesizedExpr.isParenthesized() and 
  not parenthesizedExpr instanceof Tuple and
  
  // 确定表达式在哪种语句中以及扮演的角色
  (
    // 检查是否为if语句中的条件
    exists(If i | i.getTest() = parenthesizedExpr) and 
    stmtType = "if" and 
    exprRole = "condition"
    
    or
    
    // 检查是否为while语句中的条件
    exists(While w | w.getTest() = parenthesizedExpr) and 
    stmtType = "while" and 
    exprRole = "condition"
    
    or
    
    // 检查是否为return语句中的返回值
    exists(Return r | r.getValue() = parenthesizedExpr) and 
    stmtType = "return" and 
    exprRole = "value"
    
    or
    
    // 检查是否为assert语句中的测试部分（且没有消息）
    exists(Assert a | 
      a.getTest() = parenthesizedExpr and 
      not exists(a.getMsg())
    ) and 
    stmtType = "assert" and 
    exprRole = "test"
  ) and
  
  // 排除需要括号的表达式类型
  (not parenthesizedExpr instanceof Yield and 
   not parenthesizedExpr instanceof YieldFrom and 
   not parenthesizedExpr instanceof GeneratorExp) and
  
  // 获取表达式位置并确保在同一行内
  exprLocation = parenthesizedExpr.getLocation() and 
  exprLocation.getStartLine() = exprLocation.getEndLine()

select parenthesizedExpr, "Parenthesized " + exprRole + " in '" + stmtType + "' statement."  // 选择表达式并生成描述信息