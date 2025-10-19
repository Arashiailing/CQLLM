/**
 * @name Implicit string concatenation in a list
 * @description Detects string literals that are implicitly concatenated within a list, 
 *              which may indicate a missing comma and reduce code clarity.
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
 * Determines if an expression represents a string constant,
 * which can be either a direct string literal or a result of
 * implicit string concatenation operations.
 */
predicate representsStringConstant(Expr expr) {
  // Direct string literal case
  expr instanceof StringLiteral
  // Recursive case: Binary operation that concatenates string constants
  or 
  exists(BinaryExpr concatOperation | 
    concatOperation = expr and 
    representsStringConstant(concatOperation.getLeft()) and 
    representsStringConstant(concatOperation.getRight())
  )
}

from StringLiteral targetString
where
  // The string has implicit concatenation parts
  exists(targetString.getAnImplicitlyConcatenatedPart()) and
  // The string is not explicitly parenthesized
  not targetString.isParenthesized() and
  // The string appears in a list with other string constants
  exists(List containingList |
    // The target string is an element of the list
    containingList.getAnElt() = targetString and
    // There exists another string constant in the same list
    exists(Expr neighboringString |
      neighboringString != targetString and
      containingList.getAnElt() = neighboringString and
      representsStringConstant(neighboringString)
    )
  )
select targetString, "Implicit string concatenation. Maybe missing a comma?"