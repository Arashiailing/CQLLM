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
 * including cases formed through implicit concatenation.
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
  // Condition 1: String contains implicit concatenation parts
  exists(targetString.getAnImplicitlyConcatenatedPart()) and
  // Condition 2: String is not explicitly parenthesized
  not targetString.isParenthesized() and
  // Condition 3: String appears in a list with other string constants
  exists(List containingList |
    // Verify target is an element of the list
    containingList.getAnElt() = targetString and
    // Find another string constant in the same list
    exists(Expr neighborString |
      neighborString != targetString and
      containingList.getAnElt() = neighborString and
      isStringConstant(neighborString)
    )
  )
select targetString, "Implicit string concatenation. Maybe missing a comma?"