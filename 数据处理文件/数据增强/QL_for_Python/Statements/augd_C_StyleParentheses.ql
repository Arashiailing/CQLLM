/**
 * @name C-style condition
 * @description Detects unnecessary parentheses around conditions in 'if', 'while', 'return',
 *              and 'assert' statements, which can reduce code readability.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/c-style-parentheses
 */

import python

from Expr parenthesizedExpr, Location exprLocation, string stmtType, string exprRole
where
  // Base condition: expression is wrapped in parentheses
  parenthesizedExpr.isParenthesized() and
  // Exclude tuples as they require parentheses
  not parenthesizedExpr instanceof Tuple and
  // Check if the parenthesized expression is used in specific statement contexts
  (
    // Case 1: Expression is the condition in an 'if' statement
    exists(If i | i.getTest() = parenthesizedExpr) and 
    stmtType = "if" and 
    exprRole = "condition"
    or
    // Case 2: Expression is the condition in a 'while' statement
    exists(While w | w.getTest() = parenthesizedExpr) and 
    stmtType = "while" and 
    exprRole = "condition"
    or
    // Case 3: Expression is the value in a 'return' statement
    exists(Return r | r.getValue() = parenthesizedExpr) and 
    stmtType = "return" and 
    exprRole = "value"
    or
    // Case 4: Expression is the test in an 'assert' statement without a message
    exists(Assert a | 
      a.getTest() = parenthesizedExpr and 
      not exists(a.getMsg())
    ) and
    stmtType = "assert" and
    exprRole = "test"
  ) and
  // Exclude expressions that require parentheses for syntactic correctness
  not parenthesizedExpr instanceof Yield and
  not parenthesizedExpr instanceof YieldFrom and
  not parenthesizedExpr instanceof GeneratorExp and
  // Get location information and ensure expression is on a single line
  exprLocation = parenthesizedExpr.getLocation() and
  exprLocation.getStartLine() = exprLocation.getEndLine()
select parenthesizedExpr, "Parenthesized " + exprRole + " in '" + stmtType + "' statement."