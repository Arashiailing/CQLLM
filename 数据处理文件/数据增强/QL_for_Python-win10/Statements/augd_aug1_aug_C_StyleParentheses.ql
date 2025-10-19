/**
 * @name C-style condition
 * @description Identifies Python code containing unnecessary parentheses around conditions in control flow statements.
 *              Python doesn't require these parentheses, and they reduce readability by implying
 *              C-style syntax where it's inappropriate.
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
  // Verify expression is wrapped in parentheses
  parenthesizedExpr.isParenthesized() and
  
  // Exclude tuples which syntactically require parentheses
  not parenthesizedExpr instanceof Tuple and
  
  // Ensure expression is contained within a single line of code
  exprLocation = parenthesizedExpr.getLocation() and
  exprLocation.getStartLine() = exprLocation.getEndLine() and
  
  // Filter expressions that must use parentheses for correct syntax
  not (
    parenthesizedExpr instanceof Yield or 
    parenthesizedExpr instanceof YieldFrom or 
    parenthesizedExpr instanceof GeneratorExp
  ) and
  
  // Identify statement context and component type where parenthesized expression appears
  (
    // Check for 'if' statement condition
    exists(If i | i.getTest() = parenthesizedExpr) and 
    statementType = "if" and 
    componentType = "condition"
    
    or
    
    // Check for 'while' statement condition
    exists(While w | w.getTest() = parenthesizedExpr) and 
    statementType = "while" and 
    componentType = "condition"
    
    or
    
    // Check for 'return' statement value
    exists(Return r | r.getValue() = parenthesizedExpr) and 
    statementType = "return" and 
    componentType = "value"
    
    or
    
    // Check for 'assert' statement test without message
    exists(Assert a | 
      a.getTest() = parenthesizedExpr and 
      not exists(a.getMsg())
    ) and 
    statementType = "assert" and 
    componentType = "test"
  )

// Generate results showing the parenthesized expression with contextual information
select parenthesizedExpr, "Parenthesized " + componentType + " in '" + statementType + "' statement."