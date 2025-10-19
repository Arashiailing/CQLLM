/**
 * @name C-style condition
 * @description Detects unnecessary parentheses around expressions in control flow statements.
 *              These parentheses are redundant in Python and can make code less readable.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/c-style-parentheses
 */

import python

from Expr enclosedExpr, Location sourceLocation, string stmtCategory, string exprPurpose
where
  // Verify the expression is enclosed in parentheses and not a tuple
  enclosedExpr.isParenthesized() and
  not enclosedExpr instanceof Tuple and
  
  // Determine the context where the parenthesized expression is used
  (
    // Case 1: Expression serves as condition in an if statement
    exists(If ifStmt | ifStmt.getTest() = enclosedExpr) and 
    stmtCategory = "if" and 
    exprPurpose = "condition"
    
    or
    
    // Case 2: Expression serves as condition in a while statement
    exists(While whileStmt | whileStmt.getTest() = enclosedExpr) and 
    stmtCategory = "while" and 
    exprPurpose = "condition"
    
    or
    
    // Case 3: Expression is the value in a return statement
    exists(Return returnStmt | returnStmt.getValue() = enclosedExpr) and 
    stmtCategory = "return" and 
    exprPurpose = "value"
    
    or
    
    // Case 4: Expression is the test part in an assert statement without a message
    exists(Assert assertStmt | 
      assertStmt.getTest() = enclosedExpr and 
      not exists(assertStmt.getMsg())
    ) and
    stmtCategory = "assert" and
    exprPurpose = "test"
  ) and
  
  // Exclude expression types that require parentheses
  not enclosedExpr instanceof Yield and
  not enclosedExpr instanceof YieldFrom and
  not enclosedExpr instanceof GeneratorExp and
  
  // Get the expression location and ensure it's within a single line
  sourceLocation = enclosedExpr.getLocation() and
  sourceLocation.getStartLine() = sourceLocation.getEndLine()

select enclosedExpr, "Parenthesized " + exprPurpose + " in '" + stmtCategory + "' statement."