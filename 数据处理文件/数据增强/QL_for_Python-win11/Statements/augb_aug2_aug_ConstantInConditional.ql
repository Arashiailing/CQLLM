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

// Determines if an expression is utilized within a conditional context
predicate used_as_condition(Expr conditionNode) {
  // Verifies if expression serves as test condition in if statement
  exists(If ifNode | ifNode.getTest() = conditionNode) or
  // Verifies if expression serves as test condition in conditional expression
  exists(IfExp ifExprNode | ifExprNode.getTest() = conditionNode)
}

/* Identifies specific builtin names as constants when they remain unredefined. */
predicate is_effective_constant(Name nameNode) {
  // Locates unredefined global builtin constants
  exists(GlobalVariable globalVar | 
    globalVar = nameNode.getVariable() and 
    not exists(NameNode definingNode | definingNode.defines(globalVar)) |
    globalVar.getId() = "True" or 
    globalVar.getId() = "False" or 
    globalVar.getId() = "NotImplemented"
  )
}

// Detects conditional expressions that result in unreachable code paths
predicate causes_unreachable_code(Expr conditionNode) {
  // Checks if statements where condition creates unreachable branches
  exists(If ifNode | 
    ifNode.getTest() = conditionNode and 
    (ifNode.getStmt(0).isUnreachable() or 
     ifNode.getOrelse(0).isUnreachable())
  )
  or
  // Checks while loops where condition creates unreachable loop body
  exists(While whileNode | 
    whileNode.getTest() = conditionNode and 
    whileNode.getStmt(0).isUnreachable()
  )
}

// Locates all constant expressions appearing in conditional contexts
from Expr conditionNode
where
  // Confirms expression is used in conditional context
  used_as_condition(conditionNode) and
  // Validates expression is either constant or effectively constant
  (conditionNode.isConstant() or is_effective_constant(conditionNode)) and
  /* Excludes conditions resulting in unreachable code (addressed separately) */
  // Filters out conditions leading to unreachable code (handled by different query)
  not causes_unreachable_code(conditionNode)
// Reports detection results
select conditionNode, "Testing a constant will always give the same result."