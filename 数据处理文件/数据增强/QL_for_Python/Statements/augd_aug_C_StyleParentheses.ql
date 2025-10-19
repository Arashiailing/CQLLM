/**
 * @name C-style condition
 * @description Identifies unnecessary parentheses around conditions in 'if', 'while', 'return' or 'assert' statements.
 *              Such parentheses are not required in Python and reduce code readability.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/c-style-parentheses
 */

import python  // Import Python language library for code analysis

from Expr parenExpr, Location exprLoc, string stmtType, string compType
where
  // Core condition: expression must be parenthesized
  parenExpr.isParenthesized() and
  
  // Exclude expressions requiring parentheses for valid syntax
  not (parenExpr instanceof Tuple or 
       parenExpr instanceof Yield or 
       parenExpr instanceof YieldFrom or 
       parenExpr instanceof GeneratorExp) and
  
  // Identify statement context and component type
  (
    // Case 1: Condition in 'if' statement
    exists(If i | i.getTest() = parenExpr) and 
    stmtType = "if" and 
    compType = "condition"
    
    or
    
    // Case 2: Condition in 'while' statement
    exists(While w | w.getTest() = parenExpr) and 
    stmtType = "while" and 
    compType = "condition"
    
    or
    
    // Case 3: Value in 'return' statement
    exists(Return r | r.getValue() = parenExpr) and 
    stmtType = "return" and 
    compType = "value"
    
    or
    
    // Case 4: Test in 'assert' statement (no message)
    exists(Assert a | 
      a.getTest() = parenExpr and 
      not exists(a.getMsg())
    ) and 
    stmtType = "assert" and 
    compType = "test"
  ) and
  
  // Validate location constraints: expression must be on a single line
  exprLoc = parenExpr.getLocation() and
  exprLoc.getStartLine() = exprLoc.getEndLine()

// Select results with formatted message
select parenExpr, "Parenthesized " + compType + " in '" + stmtType + "' statement."