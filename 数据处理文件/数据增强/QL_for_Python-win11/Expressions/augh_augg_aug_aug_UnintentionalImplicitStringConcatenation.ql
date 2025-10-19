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
predicate representsStringLiteralOrConcat(Expr expr) {
  // Direct string literal case
  expr instanceof StringLiteral
  // Recursive case: binary operation combining valid string expressions
  or 
  exists(BinaryExpr binaryConcatOp | 
    expr = binaryConcatOp and 
    representsStringLiteralOrConcat(binaryConcatOp.getLeft()) and 
    representsStringLiteralOrConcat(binaryConcatOp.getRight())
  )
}

from StringLiteral targetString
where
  // Verify the string participates in implicit concatenation
  exists(targetString.getAnImplicitlyConcatenatedPart()) and
  // Ensure the string isn't explicitly parenthesized
  not targetString.isParenthesized() and
  // Check if the string resides in a list containing other string constants
  exists(List containerList |
    // Confirm target string is a list element
    containerList.getAnElt() = targetString and
    // Locate another string constant in the same list
    exists(Expr coLocatedString |
      coLocatedString != targetString and
      containerList.getAnElt() = coLocatedString and
      representsStringLiteralOrConcat(coLocatedString)
    )
  )
select targetString, "Implicit string concatenation. Maybe missing a comma?"