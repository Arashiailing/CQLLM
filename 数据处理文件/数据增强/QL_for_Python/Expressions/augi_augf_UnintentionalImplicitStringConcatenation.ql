/**
 * @name Implicit string concatenation in a list
 * @description Detects when strings in a list are implicitly concatenated due to missing commas,
 *              which can lead to confusion and potential bugs.
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

// Determines if an expression is a string constant or composed of implicitly concatenated string constants
predicate isStringConstant(Expr expr) {
  // Base case: expression is a string literal
  expr instanceof StringLiteral
  // Recursive case: expression is a binary operation with both operands being string constants
  or
  isStringConstant(expr.(BinaryExpr).getLeft()) and isStringConstant(expr.(BinaryExpr).getRight())
}

// Find cases of implicit string concatenation within lists
from StringLiteral stringLiteral
where
  // Condition 1: String resides in a list containing at least two string elements
  exists(List containingList, Expr otherStringLiteral |
    // Ensure current string is different from the other string
    not stringLiteral = otherStringLiteral and
    // Current string is an element of the list
    containingList.getAnElt() = stringLiteral and
    // List contains another string element
    containingList.getAnElt() = otherStringLiteral and
    // The other element is also a string constant
    isStringConstant(otherStringLiteral)
  ) and
  // Condition 2: Current string has implicitly concatenated parts
  exists(stringLiteral.getAnImplicitlyConcatenatedPart()) and
  // Condition 3: Current string is not enclosed in parentheses
  not stringLiteral.isParenthesized()
select stringLiteral, "Implicit string concatenation. Maybe missing a comma?"