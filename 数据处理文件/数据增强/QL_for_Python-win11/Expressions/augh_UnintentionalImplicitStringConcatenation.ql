/**
 * @name Implicit string concatenation in a list
 * @description Detects string literals that are implicitly concatenated within lists,
 *              which can lead to confusion and potential errors due to missing commas.
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

/**
 * Determines if an expression represents a string constant or
 * is composed of implicitly concatenated string constants.
 */
predicate isStringConstant(Expr expr) {
  // Base case: expression is a string literal
  expr instanceof StringLiteral
  // Recursive case: binary operation combining two string constants
  or
  isStringConstant(expr.(BinaryExpr).getLeft()) and 
  isStringConstant(expr.(BinaryExpr).getRight())
}

from StringLiteral strLiteral
where
  // Find a list containing this string and at least one other string constant
  exists(List parentList, Expr siblingString |
    // Ensure the strings are distinct elements
    not strLiteral = siblingString and
    // Verify both strings exist in the same list
    parentList.getAnElt() = strLiteral and
    parentList.getAnElt() = siblingString and
    // Confirm the sibling is also a string constant
    isStringConstant(siblingString)
  ) and
  // Check for implicit concatenation in the target string
  exists(strLiteral.getAnImplicitlyConcatenatedPart()) and
  // Exclude parenthesized strings (explicit concatenation)
  not strLiteral.isParenthesized()
select strLiteral, "Implicit string concatenation. Maybe missing a comma?"