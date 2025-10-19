/**
 * @name C-style condition
 * @description Detects redundant parentheses around expressions in 'if', 'while', 'return' or 'assert' statements.
 *              These parentheses are superfluous in Python and can impair code readability.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/c-style-parentheses
 */

import python  // Import Python language library for code analysis

from Expr enclosedExpr, Location exprPos, string stmtCategory, string componentCategory
where
  // Verify the expression is wrapped in parentheses
  enclosedExpr.isParenthesized() and
  
  // Exclude tuples since they necessitate parentheses for correct syntax
  not enclosedExpr instanceof Tuple and
  
  // Identify the statement type and component where the parenthesized expression appears
  (
    // Condition in 'if' statement
    exists(If i | i.getTest() = enclosedExpr) and 
    stmtCategory = "if" and 
    componentCategory = "condition"
    
    or
    
    // Condition in 'while' statement
    exists(While w | w.getTest() = enclosedExpr) and 
    stmtCategory = "while" and 
    componentCategory = "condition"
    
    or
    
    // Value in 'return' statement
    exists(Return r | r.getValue() = enclosedExpr) and 
    stmtCategory = "return" and 
    componentCategory = "value"
    
    or
    
    // Test in 'assert' statement without message
    exists(Assert a | 
      a.getTest() = enclosedExpr and 
      not exists(a.getMsg())
    ) and 
    stmtCategory = "assert" and 
    componentCategory = "test"
  ) and
  
  // Exclude expressions that mandate parentheses for proper syntax
  (
    not enclosedExpr instanceof Yield and 
    not enclosedExpr instanceof YieldFrom and 
    not enclosedExpr instanceof GeneratorExp
  ) and
  
  // Retrieve the expression's position and confirm it's on a single line
  exprPos = enclosedExpr.getLocation() and
  exprPos.getStartLine() = exprPos.getEndLine()

// Select the parenthesized expression and generate a descriptive message
select enclosedExpr, "Parenthesized " + componentCategory + " in '" + stmtCategory + "' statement."