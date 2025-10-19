/**
 * @name Constant in conditional expression or statement
 * @description Identifies conditionals that always evaluate to true or false
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

// Determines if an expression is used as a test condition in control flow
predicate isTestCondition(Expr testExpr) {
  // Matches expressions used in if statements or conditional expressions
  exists(If ifStmt | ifStmt.getTest() = testExpr) or
  exists(IfExp condExpr | condExpr.getTest() = testExpr)
}

/* Recognizes unmodified built-in constants as effective constants */
predicate isEffectiveConstant(Name nameExpr) {
  // Identifies global constants that are never redefined
  exists(GlobalVariable globalVar | 
    globalVar = nameExpr.getVariable() and 
    not exists(NameNode defNode | defNode.defines(globalVar)) |
    globalVar.getId() = "True" or 
    globalVar.getId() = "False" or 
    globalVar.getId() = "NotImplemented"
  )
}

// Detects conditions that cause unreachable code paths
predicate createsUnreachableCode(Expr testExpr) {
  // Checks if condition leads to unreachable branches in if/while constructs
  exists(If ifStmt | 
    ifStmt.getTest() = testExpr and 
    (ifStmt.getStmt(0).isUnreachable() or ifStmt.getOrelse(0).isUnreachable())
  )
  or
  exists(While whileLoop | 
    whileLoop.getTest() = testExpr and 
    whileLoop.getStmt(0).isUnreachable()
  )
}

// Identifies constant expressions used in conditional contexts
from Expr testExpr
where
  // Expression must be used as a test condition
  isTestCondition(testExpr) and
  // Expression must be a literal constant or effective constant
  (testExpr.isConstant() or isEffectiveConstant(testExpr)) and
  /* Exclude cases causing unreachable code (handled separately) */
  not createsUnreachableCode(testExpr)
// Report the problematic constant condition
select testExpr, "Testing a constant will always give the same result."