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
 * Identifies expressions representing string constants,
 * including those formed through implicit concatenation.
 */
predicate representsStringConstant(Expr expr) {
  // Base case: Direct string literal
  expr instanceof StringLiteral
  // Recursive case: Binary operation combining string constants
  or 
  exists(BinaryExpr binOp | 
    binOp = expr and 
    representsStringConstant(binOp.getLeft()) and 
    representsStringConstant(binOp.getRight())
  )
}

from StringLiteral concatenatedString
where
  // Condition 1: String contains implicit concatenation parts
  exists(concatenatedString.getAnImplicitlyConcatenatedPart()) and
  // Condition 2: String is not explicitly parenthesized
  not concatenatedString.isParenthesized() and
  // Condition 3: String appears in a list with other string constants
  exists(List containingList |
    // Verify the string is an element of the list
    containingList.getAnElt() = concatenatedString and
    // Find another string constant in the same list
    exists(Expr neighborString |
      neighborString != concatenatedString and
      containingList.getAnElt() = neighborString and
      representsStringConstant(neighborString)
    )
  )
select concatenatedString, "Implicit string concatenation. Maybe missing a comma?"