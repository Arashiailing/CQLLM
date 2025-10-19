/**
 * @name Constant in conditional expression or statement
 * @description Detects conditionals that always evaluate to true or false due to constant expressions
 * @kind problem
 * @tags maintainability
 *       useless-code
 *       external/cwe/cwe-561
 *       external/cwe/cwe-570
 *       external/cwe/cwe-571
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/constant-conditional-expression
 */

import python

/**
 * Identifies expressions used as test conditions in control flow statements
 * @param conditionExpr - The expression being evaluated as a condition
 */
predicate is_condition(Expr conditionExpr) {
  // Check if the expression serves as the test condition in either:
  // 1. An if statement (If)
  // 2. A conditional expression (IfExp)
  exists(If ifStmt | ifStmt.getTest() = conditionExpr) or
  exists(IfExp ifExpr | ifExpr.getTest() = conditionExpr)
}

/**
 * Recognizes specific unmodified builtin constants that behave as constants
 * @param constName - The name node representing the constant
 */
predicate effective_constant(Name constName) {
  // Verify the name refers to one of these global builtin constants:
  // True, False, or NotImplemented
  // Ensure no other definitions exist for this variable
  exists(GlobalVariable globalVar | 
    globalVar = constName.getVariable() and 
    not exists(NameNode definingNode | definingNode.defines(globalVar)) |
    globalVar.getId() = "True" or 
    globalVar.getId() = "False" or 
    globalVar.getId() = "NotImplemented"
  )
}

/**
 * Determines if a test condition creates unreachable code branches
 * @param conditionExpr - The expression being evaluated
 */
predicate test_makes_code_unreachable(Expr conditionExpr) {
  // Identify if statements where either branch becomes unreachable
  // due to the constant condition
  exists(If ifStmt | 
    ifStmt.getTest() = conditionExpr and 
    (ifStmt.getStmt(0).isUnreachable() or ifStmt.getOrelse(0).isUnreachable())
  )
  or
  // Identify while loops where the body becomes unreachable
  // due to the constant condition
  exists(While whileLoop | 
    whileLoop.getTest() = conditionExpr and 
    whileLoop.getStmt(0).isUnreachable()
  )
}

// Main query to identify constant conditional expressions
from Expr conditionExpr
where
  // The expression must serve as a condition in control flow
  is_condition(conditionExpr) and
  // The expression must be either a literal constant or a recognized builtin constant
  (conditionExpr.isConstant() or effective_constant(conditionExpr)) and
  // Exclude cases where the constant condition creates unreachable code
  // (handled separately in a different query)
  not test_makes_code_unreachable(conditionExpr)
// Report findings with consistent message
select conditionExpr, "Testing a constant will always give the same result."