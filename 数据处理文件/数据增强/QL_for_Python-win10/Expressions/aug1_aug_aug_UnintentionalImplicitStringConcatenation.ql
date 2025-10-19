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
 * Identifies expressions that represent string constants,
 * including those formed by implicit concatenation.
 */
predicate representsStringConstant(Expr expression) {
  // Base case: Direct string literal
  expression instanceof StringLiteral
  // Recursive case: Binary operation combining string constants
  or 
  exists(BinaryExpr binaryOperation | 
    binaryOperation = expression and 
    representsStringConstant(binaryOperation.getLeft()) and 
    representsStringConstant(binaryOperation.getRight())
  )
}

from StringLiteral suspectString
where
  // Condition 1: The string has implicit concatenation parts
  exists(suspectString.getAnImplicitlyConcatenatedPart()) and
  // Condition 2: The string is not explicitly parenthesized
  not suspectString.isParenthesized() and
  // Condition 3: The string appears in a list with other string constants
  exists(List parentList |
    // Verify the suspect string is an element of the list
    parentList.getAnElt() = suspectString and
    // Find another string constant in the same list
    exists(Expr adjacentString |
      adjacentString != suspectString and
      parentList.getAnElt() = adjacentString and
      representsStringConstant(adjacentString)
    )
  )
select suspectString, "Implicit string concatenation. Maybe missing a comma?"