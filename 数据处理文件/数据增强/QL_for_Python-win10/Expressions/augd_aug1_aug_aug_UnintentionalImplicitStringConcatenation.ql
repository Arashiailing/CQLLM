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
 * including those formed through implicit concatenation.
 */
predicate isStringConstant(Expr expr) {
  // Base case: Direct string literal
  expr instanceof StringLiteral
  // Recursive case: Binary operation combining string constants
  or 
  exists(BinaryExpr binOp | 
    binOp = expr and 
    isStringConstant(binOp.getLeft()) and 
    isStringConstant(binOp.getRight())
  )
}

from StringLiteral targetString
where
  // The string has implicit concatenation parts
  exists(targetString.getAnImplicitlyConcatenatedPart()) and
  // The string is not explicitly parenthesized
  not targetString.isParenthesized() and
  // The string appears in a list with other string constants
  exists(List containerList |
    // Verify the target string is an element of the list
    containerList.getAnElt() = targetString and
    // Find another string constant in the same list
    exists(Expr otherString |
      otherString != targetString and
      containerList.getAnElt() = otherString and
      isStringConstant(otherString)
    )
  )
select targetString, "Implicit string concatenation. Maybe missing a comma?"