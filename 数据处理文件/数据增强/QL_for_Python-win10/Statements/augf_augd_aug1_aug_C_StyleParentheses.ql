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

from Expr parenthesizedExpression, Location expressionLocation, string stmtType, string compType
where
  // Verify expression is wrapped in parentheses
  parenthesizedExpression.isParenthesized() and
  
  // Exclude tuples which syntactically require parentheses
  not parenthesizedExpression instanceof Tuple and
  
  // Ensure expression is contained within a single line of code
  expressionLocation = parenthesizedExpression.getLocation() and
  expressionLocation.getStartLine() = expressionLocation.getEndLine() and
  
  // Filter expressions that must use parentheses for correct syntax
  not (
    parenthesizedExpression instanceof Yield or 
    parenthesizedExpression instanceof YieldFrom or 
    parenthesizedExpression instanceof GeneratorExp
  ) and
  
  // Identify statement context and component type where parenthesized expression appears
  (
    // Check for 'if' statement condition
    exists(If i | i.getTest() = parenthesizedExpression) and 
    stmtType = "if" and 
    compType = "condition"
    
    or
    
    // Check for 'while' statement condition
    exists(While w | w.getTest() = parenthesizedExpression) and 
    stmtType = "while" and 
    compType = "condition"
    
    or
    
    // Check for 'return' statement value
    exists(Return r | r.getValue() = parenthesizedExpression) and 
    stmtType = "return" and 
    compType = "value"
    
    or
    
    // Check for 'assert' statement test without message
    exists(Assert a | 
      a.getTest() = parenthesizedExpression and 
      not exists(a.getMsg())
    ) and 
    stmtType = "assert" and 
    compType = "test"
  )

// Generate results showing the parenthesized expression with contextual information
select parenthesizedExpression, "Parenthesized " + compType + " in '" + stmtType + "' statement."