/**
 * @name Constant used in conditional context
 * @description The condition is always true or always false
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

// Check if an expression is used as a condition test
predicate is_condition(Expr condExpr) {
  // Verify expression appears in test position of if statements or conditional expressions
  exists(If ifNode | ifNode.getTest() = condExpr) or
  exists(IfExp ifExpr | ifExpr.getTest() = condExpr)
}

/* Treat specific unmodified built-in names as constants. */
// Identify specific built-in constant names
predicate effective_constant(Name varName) {
  // Find global built-in constants that haven't been redefined
  exists(GlobalVariable globalSymbol | 
    globalSymbol = varName.getVariable() and 
    not exists(NameNode definingNode | definingNode.defines(globalSymbol)) |
    globalSymbol.getId() = "True" or 
    globalSymbol.getId() = "False" or 
    globalSymbol.getId() = "NotImplemented"
  )
}

// Detect conditions that make code unreachable
predicate test_makes_code_unreachable(Expr condExpr) {
  // Check if conditions in if statements create unreachable branches
  exists(If ifNode | 
    ifNode.getTest() = condExpr and 
    (ifNode.getStmt(0).isUnreachable() or 
     ifNode.getOrelse(0).isUnreachable())
  )
  or
  // Check if conditions in while loops create unreachable bodies
  exists(While whileNode | 
    whileNode.getTest() = condExpr and 
    whileNode.getStmt(0).isUnreachable()
  )
}

// Find all constant expressions used in conditional contexts
from Expr condExpr
where
  // Ensure the expression is used in a conditional context
  is_condition(condExpr) and
  // Check if the expression is a constant or effectively constant
  (condExpr.isConstant() or effective_constant(condExpr)) and
  /* Exclude conditions that make code unreachable (handled by separate query) */
  // Exclude conditions that make code unreachable (handled by a separate query)
  not test_makes_code_unreachable(condExpr)
// Report findings
select condExpr, "Testing a constant will always give the same result."