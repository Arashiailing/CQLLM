/**
 * @name Implicit string concatenation in a list
 * @description Detects implicit string concatenation in lists which may indicate missing commas
 * @kind problem
 * @tags reliability
 *       maintainability
 *       convention
 *       external/cwe/cwe-665
 * @problem.severity warning
 * @sub-severity high
 * @precision high
 * @id py/implicit-string-concatenation-in-list
 */

import python

// Recursively identifies string constants (literal or implicitly concatenated)
predicate isStringConstant(Expr expr) {
  // Base case: expression is a string literal
  expr instanceof StringLiteral
  // Recursive case: both operands of binary expression are string constants
  or 
  isStringConstant(expr.(BinaryExpr).getLeft()) and 
  isStringConstant(expr.(BinaryExpr).getRight())
}

// Query starts from string literals
from StringLiteral strLiteral
where
  // String must contain implicit concatenation
  exists(strLiteral.getAnImplicitlyConcatenatedPart()) and
  // String must not be parenthesized
  not strLiteral.isParenthesized() and
  // String must reside in a list containing another string constant
  exists(List containerList, Expr otherStr |
    containerList.getAnElt() = strLiteral and
    containerList.getAnElt() = otherStr and
    not strLiteral = otherStr and
    isStringConstant(otherStr)
  )
select strLiteral, "Implicit string concatenation. Maybe missing a comma?"