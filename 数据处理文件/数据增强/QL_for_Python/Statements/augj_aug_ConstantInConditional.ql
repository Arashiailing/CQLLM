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

/* Identifies specific built-in constants that remain unmodified */
predicate effective_constant(Name nameNode) {
  // Find global built-in constants that haven't been redefined
  exists(GlobalVariable globalVar | 
    globalVar = nameNode.getVariable() and 
    not exists(NameNode defNode | defNode.defines(globalVar)) |
    globalVar.getId() = "True" or 
    globalVar.getId() = "False" or 
    globalVar.getId() = "NotImplemented"
  )
}

// Determines if an expression is used in a conditional context
predicate is_condition(Expr condExpr) {
  // Check for usage in if statements or conditional expressions
  exists(If ifNode | ifNode.getTest() = condExpr) or
  exists(IfExp ifExpNode | ifExpNode.getTest() = condExpr)
}

// Detects conditions that result in unreachable code paths
predicate test_makes_code_unreachable(Expr condExpr) {
  // Check if condition makes if-statement branches unreachable
  exists(If ifNode | 
    ifNode.getTest() = condExpr and 
    (ifNode.getStmt(0).isUnreachable() or 
     ifNode.getOrelse(0).isUnreachable())
  )
  or
  // Check if condition makes while-loop body unreachable
  exists(While whileNode | 
    whileNode.getTest() = condExpr and 
    whileNode.getStmt(0).isUnreachable()
  )
}

// Find all constant expressions used in conditional contexts
from Expr condExpr
where
  // Verify expression is used in conditional context
  is_condition(condExpr) and
  // Check if expression is constant or effectively constant
  (condExpr.isConstant() or effective_constant(condExpr)) and
  /* Exclude conditions that make code unreachable (handled by separate query) */
  // Filter out cases causing unreachable code (handled by other query)
  not test_makes_code_unreachable(condExpr)
// Report findings with consistent message
select condExpr, "Testing a constant will always give the same result."