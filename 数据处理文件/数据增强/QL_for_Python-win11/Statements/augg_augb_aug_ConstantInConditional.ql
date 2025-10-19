/**
 * @name Constant used in conditional context
 * @description The condition is always true or always false
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

// Determine if an expression is used in a conditional test context
predicate is_condition(Expr conditionExpr) {
  // Check if the expression is the test part of an if statement
  exists(If ifStmt | ifStmt.getTest() = conditionExpr)
  or
  // Check if the expression is the test part of a conditional expression
  exists(IfExp conditionalExpr | conditionalExpr.getTest() = conditionExpr)
}

// Identify specific built-in names that should be treated as constants
predicate effective_constant(Name nameNode) {
  // Find global built-in constants that haven't been redefined in the code
  exists(GlobalVariable globalVar | 
    globalVar = nameNode.getVariable() and 
    not exists(NameNode definitionNode | definitionNode.defines(globalVar)) |
    globalVar.getId() = "True" or 
    globalVar.getId() = "False" or 
    globalVar.getId() = "NotImplemented"
  )
}

// Detect conditions that result in unreachable code blocks
predicate test_makes_code_unreachable(Expr conditionExpr) {
  // Check if conditions in if statements create unreachable branches
  exists(If ifStmt | 
    ifStmt.getTest() = conditionExpr and 
    (ifStmt.getStmt(0).isUnreachable() or 
     ifStmt.getOrelse(0).isUnreachable())
  )
  or
  // Check if conditions in while loops create unreachable bodies
  exists(While whileStmt | 
    whileStmt.getTest() = conditionExpr and 
    whileStmt.getStmt(0).isUnreachable()
  )
}

// Identify all constant expressions used in conditional contexts
from Expr conditionExpr
where
  // Verify the expression is used in a conditional context
  is_condition(conditionExpr) and
  // Determine if the expression is a constant or effectively constant
  (conditionExpr.isConstant() or effective_constant(conditionExpr)) and
  // Filter out conditions that make code unreachable (handled by a separate query)
  not test_makes_code_unreachable(conditionExpr)
// Report the findings
select conditionExpr, "Testing a constant will always give the same result."