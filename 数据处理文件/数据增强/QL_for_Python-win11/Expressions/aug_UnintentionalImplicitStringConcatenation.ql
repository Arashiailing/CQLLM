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

// Predicate to identify string constants including implicitly concatenated strings
predicate isStringConstant(Expr expr) {
  // Base case: Direct string literal
  expr instanceof StringLiteral
  // Recursive case: Binary expression with string constant operands
  or
  isStringConstant(expr.(BinaryExpr).getLeft()) and isStringConstant(expr.(BinaryExpr).getRight())
}

// Main query targeting string literals in lists
from StringLiteral strLiteral
where
  // Condition 1: String is part of a list containing other string constants
  exists(List containerList, Expr otherString |
    // Verify different elements in the same list
    not strLiteral = otherString and
    containerList.getAnElt() = strLiteral and
    containerList.getAnElt() = otherString and
    isStringConstant(otherString)
  ) and
  // Condition 2: String has implicit concatenation components
  exists(strLiteral.getAnImplicitlyConcatenatedPart()) and
  // Condition 3: String is not explicitly parenthesized
  not strLiteral.isParenthesized()
select strLiteral, "Implicit string concatenation detected. Consider adding missing comma?"