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

// Identifies expressions used within conditional contexts
predicate isConditionContext(Expr conditionExpr) {
  // Expression serves as test condition in if statement
  exists(If ifStatement | ifStatement.getTest() = conditionExpr) or
  // Expression serves as test part in conditional expression
  exists(IfExp ifExpression | ifExpression.getTest() = conditionExpr)
}

/* Recognizes specific built-in names that function as constants */
// Identifies unmodified built-in constant names
predicate isEffectiveConstant(Name constName) {
  // Locate global built-in variables that haven't been redefined
  exists(GlobalVariable globalVariable | 
    globalVariable = constName.getVariable() and 
    not exists(NameNode definitionNode | definitionNode.defines(globalVariable)) |
    globalVariable.getId() = "True" or 
    globalVariable.getId() = "False" or 
    globalVariable.getId() = "NotImplemented"
  )
}

// Detects conditional expressions that result in unreachable code paths
predicate generatesUnreachableCode(Expr conditionExpr) {
  // Check if condition in if statement creates unreachable branches
  exists(If ifStatement | 
    ifStatement.getTest() = conditionExpr and 
    (ifStatement.getStmt(0).isUnreachable() or 
     ifStatement.getOrelse(0).isUnreachable())
  )
  or
  // Check if condition in while loop creates unreachable body
  exists(While whileStatement | 
    whileStatement.getTest() = conditionExpr and 
    whileStatement.getStmt(0).isUnreachable()
  )
}

// Locate constant expressions used in conditional contexts
from Expr conditionExpr
where
  // Confirm expression is used in conditional context
  isConditionContext(conditionExpr) and
  // Determine if expression is constant or effectively constant
  (conditionExpr.isConstant() or isEffectiveConstant(conditionExpr)) and
  /* Exclude conditions that produce unreachable code (handled separately) */
  // Filter out scenarios leading to unreachable code
  not generatesUnreachableCode(conditionExpr)
// Report findings with appropriate message
select conditionExpr, "Testing a constant will always give the same result."