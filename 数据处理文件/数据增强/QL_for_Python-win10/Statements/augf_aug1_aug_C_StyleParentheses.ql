/**
 * @name C-style condition
 * @description Identifies Python code containing superfluous parentheses around expressions
 *              in control flow constructs. Python's syntax doesn't require these parentheses,
 *              and their presence can reduce code readability by implying C-style conventions.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/c-style-parentheses
 */

import python

from Expr wrappedExpr, Location exprLocation, string statementKind, string componentRole
where
  // Confirm the expression is enclosed in parentheses
  wrappedExpr.isParenthesized() and
  
  // Exclude tuples which syntactically mandate parentheses
  not wrappedExpr instanceof Tuple and
  
  // Validate the expression is confined to a single line
  exprLocation = wrappedExpr.getLocation() and
  exprLocation.getStartLine() = exprLocation.getEndLine() and
  
  // Filter out expressions requiring parentheses for syntactic correctness
  not (
    wrappedExpr instanceof Yield or 
    wrappedExpr instanceof YieldFrom or 
    wrappedExpr instanceof GeneratorExp
  ) and
  
  // Determine the statement context and component classification
  (
    // Handle 'if' statement conditions
    exists(If i | i.getTest() = wrappedExpr) and 
    statementKind = "if" and 
    componentRole = "condition"
    
    or
    
    // Handle 'while' statement conditions
    exists(While w | w.getTest() = wrappedExpr) and 
    statementKind = "while" and 
    componentRole = "condition"
    
    or
    
    // Handle 'return' statement values
    exists(Return r | r.getValue() = wrappedExpr) and 
    statementKind = "return" and 
    componentRole = "value"
    
    or
    
    // Handle 'assert' statement tests without messages
    exists(Assert a | 
      a.getTest() = wrappedExpr and 
      not exists(a.getMsg())
    ) and 
    statementKind = "assert" and 
    componentRole = "test"
  )

// Output results highlighting the parenthesized expression with contextual details
select wrappedExpr, "Parenthesized " + componentRole + " in '" + statementKind + "' statement."