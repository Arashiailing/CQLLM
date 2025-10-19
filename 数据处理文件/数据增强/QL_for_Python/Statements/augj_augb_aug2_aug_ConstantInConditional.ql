/**
 * @name Constant in conditional expression or statement
 * @description Identifies conditional expressions that always evaluate to the same
 *              result due to containing constant values or builtin constants.
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

// Check if expression is used in conditional context
predicate used_as_condition(Expr conditionExpr) {
  // Verify usage as test condition in if statements
  exists(If ifStmt | ifStmt.getTest() = conditionExpr) or
  // Verify usage as test condition in conditional expressions
  exists(IfExp ifExp | ifExp.getTest() = conditionExpr)
}

/* Identify builtin names that remain constant when unredefined */
predicate is_effective_constant(Name nameExpr) {
  // Locate unredefined global builtin constants
  exists(GlobalVariable builtinConstant | 
    builtinConstant = nameExpr.getVariable() and 
    not exists(NameNode redefinitionNode | redefinitionNode.defines(builtinConstant)) |
    builtinConstant.getId() = "True" or 
    builtinConstant.getId() = "False" or 
    builtinConstant.getId() = "NotImplemented"
  )
}

// Detect conditions causing unreachable code paths
predicate causes_unreachable_code(Expr conditionExpr) {
  // Check if statements with unreachable branches
  exists(If ifStmt | 
    ifStmt.getTest() = conditionExpr and 
    (ifStmt.getStmt(0).isUnreachable() or 
     ifStmt.getOrelse(0).isUnreachable())
  )
  or
  // Check while loops with unreachable body
  exists(While whileStmt | 
    whileStmt.getTest() = conditionExpr and 
    whileStmt.getStmt(0).isUnreachable()
  )
}

// Find constant expressions in conditional contexts
from Expr conditionExpr
where
  // Confirm conditional context usage
  used_as_condition(conditionExpr) and
  // Validate constant or effectively constant status
  (conditionExpr.isConstant() or is_effective_constant(conditionExpr)) and
  /* Exclude conditions leading to unreachable code (handled separately) */
  not causes_unreachable_code(conditionExpr)
// Report detection results
select conditionExpr, "Testing a constant will always give the same result."