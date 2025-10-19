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

from Expr parenthesizedExpr, Location exprLocation, string statementType, string componentType
where
  // Check if the expression is enclosed in parentheses
  parenthesizedExpr.isParenthesized() and
  
  // Exclude tuples as they require parentheses for proper syntax
  not parenthesizedExpr instanceof Tuple and
  
  // Determine the statement type and component where the parenthesized expression is used
  (
    // Case 1: Expression is the condition in an 'if' statement
    exists(If i | i.getTest() = parenthesizedExpr) and 
    statementType = "if" and 
    componentType = "condition"
    
    or
    
    // Case 2: Expression is the condition in a 'while' statement
    exists(While w | w.getTest() = parenthesizedExpr) and 
    statementType = "while" and 
    componentType = "condition"
    
    or
    
    // Case 3: Expression is the value in a 'return' statement
    exists(Return r | r.getValue() = parenthesizedExpr) and 
    statementType = "return" and 
    componentType = "value"
    
    or
    
    // Case 4: Expression is the test in an 'assert' statement without a message
    exists(Assert a | 
      a.getTest() = parenthesizedExpr and 
      not exists(a.getMsg())
    ) and 
    statementType = "assert" and 
    componentType = "test"
  ) and
  
  // Exclude expressions that require parentheses for proper syntax
  (
    not parenthesizedExpr instanceof Yield and 
    not parenthesizedExpr instanceof YieldFrom and 
    not parenthesizedExpr instanceof GeneratorExp
  ) and
  
  // Get the location of the expression and ensure it's on a single line
  exprLocation = parenthesizedExpr.getLocation() and
  exprLocation.getStartLine() = exprLocation.getEndLine()

// Select the parenthesized expression and generate a descriptive message
select parenthesizedExpr, "Parenthesized " + componentType + " in '" + statementType + "' statement."