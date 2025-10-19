/**
 * @name Implicit string concatenation in a list
 * @description Detects string literals that are implicitly concatenated within list structures.
 *              This pattern typically suggests an omitted comma between list elements, potentially
 *              causing reduced code clarity and maintenance challenges.
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

// Identifies expressions that are either direct string literals or composed of concatenated string literals
predicate isStringLiteralOrConcat(Expr expr) {
  // Direct string literal case
  expr instanceof StringLiteral
  // Recursive case: binary operation combining valid string expressions
  or 
  exists(BinaryExpr concatOperation | 
    expr = concatOperation and 
    isStringLiteralOrConcat(concatOperation.getLeft()) and 
    isStringLiteralOrConcat(concatOperation.getRight())
  )
}

from StringLiteral implicitConcatString
where
  // Verify the string participates in implicit concatenation
  exists(implicitConcatString.getAnImplicitlyConcatenatedPart()) and
  // Ensure the string isn't explicitly parenthesized
  not implicitConcatString.isParenthesized() and
  // Check if the string resides in a list containing other string constants
  exists(List parentList |
    // Confirm target string is a list element
    parentList.getAnElt() = implicitConcatString and
    // Locate another string constant in the same list
    exists(Expr neighborString |
      neighborString != implicitConcatString and
      parentList.getAnElt() = neighborString and
      isStringLiteralOrConcat(neighborString)
    )
  )
select implicitConcatString, "Implicit string concatenation. Maybe missing a comma?"