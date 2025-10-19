/**
 * @name Implicit string concatenation in a list
 * @description Identifies string literals that are implicitly concatenated within a list context.
 *              This pattern often indicates a missing comma between list elements and can lead to
 *              reduced code readability and potential maintenance issues.
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

// Determines if an expression represents a string literal or a concatenation of string literals
predicate isStringLiteralOrConcatenation(Expr expr) {
  // Base case: Expression is a direct string literal
  expr instanceof StringLiteral
  // Recursive case: Expression is a binary operation combining string literals
  or 
  exists(BinaryExpr concatenationOp | 
    expr = concatenationOp and 
    isStringLiteralOrConcatenation(concatenationOp.getLeft()) and 
    isStringLiteralOrConcatenation(concatenationOp.getRight())
  )
}

from StringLiteral suspectString
where
  // Condition 1: Verify the string is part of an implicit concatenation
  exists(suspectString.getAnImplicitlyConcatenatedPart()) and
  // Condition 2: Ensure the string is not explicitly wrapped in parentheses
  not suspectString.isParenthesized() and
  // Condition 3: Check if the string appears within a list containing other string constants
  exists(List parentList |
    // Verify the suspect string is an element of the list
    parentList.getAnElt() = suspectString and
    // Find another string constant in the same list
    exists(Expr adjacentString |
      adjacentString != suspectString and
      parentList.getAnElt() = adjacentString and
      isStringLiteralOrConcatenation(adjacentString)
    )
  )
select suspectString, "Implicit string concatenation. Maybe missing a comma?"