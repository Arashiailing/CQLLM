/**
 * @name Constant in conditional expression or statement
 * @description Detects conditional expressions or statements that always evaluate to true or false due to the use of constants
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

// Determines whether an expression is used in a conditional context
predicate is_condition(Expr testExpr) {
  // Checks if the expression appears as the test in an if statement or conditional expression
  exists(If ifNode | ifNode.getTest() = testExpr) or
  exists(IfExp ternaryExpr | ternaryExpr.getTest() = testExpr)
}

/* Treat certain unmodified builtins as constants as well. */
// Identifies specific built-in constant names that are effectively constants
predicate effective_constant(Name identifierNode) {
  // Finds global built-in constants that have not been redefined
  exists(GlobalVariable builtinVar | 
    builtinVar = identifierNode.getVariable() and 
    not exists(NameNode defNode | defNode.defines(builtinVar)) and
    (builtinVar.getId() = "True" or 
     builtinVar.getId() = "False" or 
     builtinVar.getId() = "NotImplemented")
  )
}

// Detects conditions that lead to unreachable code in control structures
predicate test_makes_code_unreachable(Expr conditionExpr) {
  // Checks conditions in if statements that make a branch unreachable
  (exists(If conditionalStmt | 
    conditionalStmt.getTest() = conditionExpr and 
    (conditionalStmt.getStmt(0).isUnreachable() or 
     conditionalStmt.getOrelse(0).isUnreachable()))
  )
  or
  // Checks conditions in while loops that make the loop body unreachable
  (exists(While loopStmt | 
    loopStmt.getTest() = conditionExpr and 
    loopStmt.getStmt(0).isUnreachable())
  )
}

// Finds all constant expressions used in conditional contexts
from Expr conditionalExpr
where
  // Ensures the expression is used in a conditional context
  is_condition(conditionalExpr) and
  // Checks if the expression is a constant or effectively a constant
  (conditionalExpr.isConstant() or effective_constant(conditionalExpr)) and
  /* Exclude conditions that make code unreachable (handled by separate query) */
  // Excludes cases that lead to unreachable code (handled by a separate query)
  not test_makes_code_unreachable(conditionalExpr)
// Reports the findings
select conditionalExpr, "Testing a constant will always give the same result."