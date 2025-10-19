/**
 * @name Constant in conditional expression or statement
 * @description The conditional is always true or always false
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

// Determines if an expression serves as a test condition in control flow
predicate is_condition(Expr testExpr) {
  // Check if expression is used as test condition in if statements
  exists(If ifStmt | ifStmt.getTest() = testExpr) or
  // Check if expression is used as test condition in conditional expressions
  exists(IfExp ifExpr | ifExpr.getTest() = testExpr)
}

/* Treat specific unmodified builtins as constants */
predicate effective_constant(Name nameExpr) {
  // Verify the name refers to a global variable
  exists(GlobalVariable globalVar | 
    globalVar = nameExpr.getVariable() and
    // Ensure no redefinition exists for this variable
    not exists(NameNode nameNode | nameNode.defines(globalVar)) |
      // Check for specific builtin constant names
      globalVar.getId() = "True" or 
      globalVar.getId() = "False" or 
      globalVar.getId() = "NotImplemented"
  )
}

// Identifies test conditions that create unreachable code paths
predicate test_makes_code_unreachable(Expr testExpr) {
  // Check if statements with unreachable branches
  exists(If ifStmt | 
    ifStmt.getTest() = testExpr and 
    (ifStmt.getStmt(0).isUnreachable() or ifStmt.getOrelse(0).isUnreachable())
  )
  or
  // Check while loops with unreachable body
  exists(While whileLoop | 
    whileLoop.getTest() = testExpr and 
    whileLoop.getStmt(0).isUnreachable()
  )
}

// Select expressions meeting all criteria
from Expr testExpr
where
  // Must be a condition in control flow
  is_condition(testExpr) and
  // Must be either a literal constant or effective builtin constant
  (testExpr.isConstant() or effective_constant(testExpr)) and
  /* Exclude cases causing unreachable code (handled by separate query) */
  not test_makes_code_unreachable(testExpr)
// Report the constant test expression with descriptive message
select testExpr, "Testing a constant will always give the same result."