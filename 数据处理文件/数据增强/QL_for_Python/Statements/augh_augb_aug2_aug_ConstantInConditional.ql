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

/**
 * Determines if an expression is utilized within a conditional context.
 * This predicate checks if the expression serves as a test condition in 
 * either an if statement or a conditional expression (ternary operator).
 */
predicate is_condition_context(Expr testExpr) {
  // Expression is used as the test condition in an if statement
  exists(If ifStmt | ifStmt.getTest() = testExpr) or
  // Expression is used as the test condition in a conditional expression
  exists(IfExp ternaryExpr | ternaryExpr.getTest() = testExpr)
}

/**
 * Identifies builtin names that behave as constants when they are not redefined.
 * This includes the standard Python boolean values and the NotImplemented sentinel.
 */
predicate is_builtin_constant(Name constName) {
  // Find unredefined global builtin constants
  exists(GlobalVariable builtinConst | 
    builtinConst = constName.getVariable() and 
    not exists(NameNode redefNode | redefNode.defines(builtinConst)) |
    builtinConst.getId() = "True" or 
    builtinConst.getId() = "False" or 
    builtinConst.getId() = "NotImplemented"
  )
}

/**
 * Detects conditional expressions that result in unreachable code paths.
 * This includes if statements with unreachable branches and while loops
 * with unreachable bodies due to constant conditions.
 */
predicate creates_unreachable_code(Expr condExpr) {
  // Check if statements where condition creates unreachable branches
  exists(If ifStmt | 
    ifStmt.getTest() = condExpr and 
    (ifStmt.getStmt(0).isUnreachable() or 
     ifStmt.getOrelse(0).isUnreachable())
  )
  or
  // Check while loops where condition creates unreachable loop body
  exists(While whileLoop | 
    whileLoop.getTest() = condExpr and 
    whileLoop.getStmt(0).isUnreachable()
  )
}

// Main query to locate constant expressions in conditional contexts
from Expr conditionalExpr
where
  // Confirm expression is used in a conditional context
  is_condition_context(conditionalExpr) and
  // Validate expression is either a literal constant or an effective builtin constant
  (conditionalExpr.isConstant() or is_builtin_constant(conditionalExpr)) and
  // Exclude conditions that result in unreachable code (handled by separate query)
  not creates_unreachable_code(conditionalExpr)
// Report the detection results
select conditionalExpr, "Testing a constant will always give the same result."