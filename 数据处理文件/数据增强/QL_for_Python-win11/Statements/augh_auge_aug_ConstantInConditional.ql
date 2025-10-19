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

// Determine if an expression is used in a conditional context
predicate usedAsCondition(Expr condExpr) {
  // Check if expression serves as test condition in if statement
  exists(If ifStmt | ifStmt.getTest() = condExpr) or
  // Check if expression serves as test part in conditional expression
  exists(IfExp ifExp | ifExp.getTest() = condExpr)
}

/* Identify specific unmodified built-in names as constants */
// Recognize unmodified built-in constant names
predicate effective_constant(Name constantName) {
  // Find global built-in variables that haven't been redefined
  exists(GlobalVariable globalVar | 
    globalVar = constantName.getVariable() and 
    not exists(NameNode defNode | defNode.defines(globalVar)) |
    globalVar.getId() = "True" or 
    globalVar.getId() = "False" or 
    globalVar.getId() = "NotImplemented"
  )
}

// Detect conditional expressions that result in unreachable code
predicate createsUnreachableCode(Expr condExpr) {
  // Check if condition in if statement makes branch unreachable
  exists(If ifStmt | 
    ifStmt.getTest() = condExpr and 
    (ifStmt.getStmt(0).isUnreachable() or 
     ifStmt.getOrelse(0).isUnreachable())
  )
  or
  // Check if condition in while loop makes body unreachable
  exists(While whileStmt | 
    whileStmt.getTest() = condExpr and 
    whileStmt.getStmt(0).isUnreachable()
  )
}

// Find constant expressions used in conditional contexts
from Expr condExpr
where
  // Verify expression is used in conditional context
  usedAsCondition(condExpr) and
  // Check if expression is constant or effectively constant
  (condExpr.isConstant() or effective_constant(condExpr)) and
  /* Exclude conditions that create unreachable code (handled separately) */
  // Filter out cases leading to unreachable code
  not createsUnreachableCode(condExpr)
// Report findings
select condExpr, "Testing a constant will always give the same result."