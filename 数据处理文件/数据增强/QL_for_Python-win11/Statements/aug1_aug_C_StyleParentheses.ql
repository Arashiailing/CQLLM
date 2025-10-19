/**
 * @name C-style condition
 * @description Detects Python code with unnecessary parentheses around conditions in control flow statements.
 *              Python doesn't require these parentheses, and they make code less readable by suggesting
 *              C-style syntax where it's not needed.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/c-style-parentheses
 */

import python  // Import Python language library for code analysis

from Expr parenthesizedCondition, Location conditionLocation, string stmtType, string compType
where
  // Verify the expression is wrapped in parentheses
  parenthesizedCondition.isParenthesized() and
  
  // Exclude tuples which syntactically require parentheses
  not parenthesizedCondition instanceof Tuple and
  
  // Ensure the expression is contained within a single line of code
  conditionLocation = parenthesizedCondition.getLocation() and
  conditionLocation.getStartLine() = conditionLocation.getEndLine() and
  
  // Filter out expressions that must use parentheses for correct syntax
  (
    not parenthesizedCondition instanceof Yield and 
    not parenthesizedCondition instanceof YieldFrom and 
    not parenthesizedCondition instanceof GeneratorExp
  ) and
  
  // Identify the statement context and component type where the parenthesized expression appears
  (
    // Check for 'if' statement condition
    exists(If i | i.getTest() = parenthesizedCondition) and 
    stmtType = "if" and 
    compType = "condition"
    
    or
    
    // Check for 'while' statement condition
    exists(While w | w.getTest() = parenthesizedCondition) and 
    stmtType = "while" and 
    compType = "condition"
    
    or
    
    // Check for 'return' statement value
    exists(Return r | r.getValue() = parenthesizedCondition) and 
    stmtType = "return" and 
    compType = "value"
    
    or
    
    // Check for 'assert' statement test without message
    exists(Assert a | 
      a.getTest() = parenthesizedCondition and 
      not exists(a.getMsg())
    ) and 
    stmtType = "assert" and 
    compType = "test"
  )

// Generate results showing the parenthesized expression with contextual information
select parenthesizedCondition, "Parenthesized " + compType + " in '" + stmtType + "' statement."