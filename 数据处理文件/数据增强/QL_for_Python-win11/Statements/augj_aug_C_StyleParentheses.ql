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

from Expr enclosedExpr, Location exprLoc, string stmtType, string compType
where
  // Verify expression has unnecessary parentheses
  enclosedExpr.isParenthesized() and
  
  // Exclude expressions requiring parentheses for syntax validity
  not enclosedExpr instanceof Tuple and
  not enclosedExpr instanceof Yield and
  not enclosedExpr instanceof YieldFrom and
  not enclosedExpr instanceof GeneratorExp and
  
  // Identify statement context and component type
  (
    // Case: Condition in 'if' statement
    exists(If i | i.getTest() = enclosedExpr) and 
    stmtType = "if" and 
    compType = "condition"
    
    or
    
    // Case: Condition in 'while' statement
    exists(While w | w.getTest() = enclosedExpr) and 
    stmtType = "while" and 
    compType = "condition"
    
    or
    
    // Case: Value in 'return' statement
    exists(Return r | r.getValue() = enclosedExpr) and 
    stmtType = "return" and 
    compType = "value"
    
    or
    
    // Case: Test in 'assert' statement (without message)
    exists(Assert a | 
      a.getTest() = enclosedExpr and 
      not exists(a.getMsg())
    ) and 
    stmtType = "assert" and 
    compType = "test"
  ) and
  
  // Ensure expression is contained on a single line
  exprLoc = enclosedExpr.getLocation() and
  exprLoc.getStartLine() = exprLoc.getEndLine()

// Output the parenthesized expression with contextual message
select enclosedExpr, "Parenthesized " + compType + " in '" + stmtType + "' statement."