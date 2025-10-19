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

// Check if an expression is used in a conditional context
predicate is_used_in_condition(Expr conditionalExpr) {
  // Expression is the test condition of an if statement
  exists(If ifStmt | ifStmt.getTest() = conditionalExpr) or
  // Expression is the test condition of a conditional expression (ternary operator)
  exists(IfExp conditionalExprNode | conditionalExprNode.getTest() = conditionalExpr)
}

// Identify builtin names that are constants when not redefined
predicate is_builtin_constant(Name nameExpr) {
  // Find global builtin constants that haven't been redefined
  exists(GlobalVariable globalVariable | 
    globalVariable = nameExpr.getVariable() and 
    not exists(NameNode definingName | definingName.defines(globalVariable)) |
    globalVariable.getId() = "True" or 
    globalVariable.getId() = "False" or 
    globalVariable.getId() = "NotImplemented"
  )
}

// Detect conditional expressions that result in unreachable code
predicate leads_to_unreachable_code(Expr conditionalExpr) {
  // Check if statements with unreachable branches due to constant condition
  exists(If ifStmt | 
    ifStmt.getTest() = conditionalExpr and 
    (ifStmt.getStmt(0).isUnreachable() or 
     ifStmt.getOrelse(0).isUnreachable())
  )
  or
  // Check while loops with unreachable body due to constant condition
  exists(While whileStmt | 
    whileStmt.getTest() = conditionalExpr and 
    whileStmt.getStmt(0).isUnreachable()
  )
}

// Find constant expressions used in conditional contexts
from Expr conditionalExpr
where
  // Expression is used in a conditional context
  is_used_in_condition(conditionalExpr) and
  // Expression is either a constant or an effective builtin constant
  (conditionalExpr.isConstant() or is_builtin_constant(conditionalExpr)) and
  // Exclude conditions that result in unreachable code (handled by a separate query)
  not leads_to_unreachable_code(conditionalExpr)
// Report the findings
select conditionalExpr, "Testing a constant will always give the same result."