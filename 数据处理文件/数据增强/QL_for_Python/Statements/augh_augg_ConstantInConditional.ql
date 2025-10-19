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

// Determines if an expression serves as a condition in control flow statements
predicate usedAsCondition(Expr conditionExpr) {
  // Checks if the expression is used in if statements or conditional expressions
  exists(If ifNode | ifNode.getTest() = conditionExpr) or
  exists(IfExp conditionalExpr | conditionalExpr.getTest() = conditionExpr)
}

/* Identifies built-in constants that remain unchanged throughout the code */
predicate isUnchangedConstant(Name constantName) {
  // Finds global constants that are never redefined after their initial declaration
  exists(GlobalVariable globalConstant | 
    globalConstant = constantName.getVariable() and 
    not exists(NameNode redefinition | redefinition.defines(globalConstant)) |
    globalConstant.getId() = "True" or 
    globalConstant.getId() = "False" or 
    globalConstant.getId() = "NotImplemented"
  )
}

// Identifies conditions that result in unreachable code sections
predicate leadsToUnreachableCode(Expr conditionExpr) {
  // Detects if the condition creates unreachable branches in if or while constructs
  exists(If ifNode | 
    ifNode.getTest() = conditionExpr and 
    (ifNode.getStmt(0).isUnreachable() or ifNode.getOrelse(0).isUnreachable())
  )
  or
  exists(While whileNode | 
    whileNode.getTest() = conditionExpr and 
    whileNode.getStmt(0).isUnreachable()
  )
}

// Main query to find constant expressions used in conditional contexts
from Expr conditionalExpr
where
  // The expression must be used as a condition in control flow
  usedAsCondition(conditionalExpr) and
  // The expression must be either a literal constant or an unchanged built-in constant
  (conditionalExpr.isConstant() or isUnchangedConstant(conditionalExpr)) and
  /* Exclude cases that lead to unreachable code (these are handled separately) */
  not leadsToUnreachableCode(conditionalExpr)
// Report the problematic constant condition
select conditionalExpr, "Testing a constant will always give the same result."