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
predicate isStringConst(Expr expr) {
  // Base case: expression is a string literal
  expr instanceof StringLiteral
  // Recursive case: both operands of binary expression are string constants
  or 
  isStringConst(expr.(BinaryExpr).getLeft()) and 
  isStringConst(expr.(BinaryExpr).getRight())
}

// Query starts from string literals
from StringLiteral stringLiteral
where
  // Check for implicit concatenation
  exists(stringLiteral.getAnImplicitlyConcatenatedPart()) and
  // Ensure the string is not parenthesized
  not stringLiteral.isParenthesized() and
  // Find a list containing this string and another string constant
  exists(List parentList, Expr anotherString |
    // Both strings are elements of the same list
    parentList.getAnElt() = stringLiteral and
    parentList.getAnElt() = anotherString and
    // They are different strings
    not stringLiteral = anotherString and
    // The other element is also a string constant
    isStringConst(anotherString)
  )
select stringLiteral, "Implicit string concatenation. Maybe missing a comma?"