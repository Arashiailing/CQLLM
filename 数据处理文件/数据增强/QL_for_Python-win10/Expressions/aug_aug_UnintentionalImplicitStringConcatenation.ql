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

// Identifies string constants including implicitly concatenated strings
predicate isStringConstant(Expr expr) {
  // Base case: Direct string literal
  expr instanceof StringLiteral
  // Recursive case: Binary operation between string constants
  or 
  exists(BinaryExpr binOp | 
    binOp = expr and 
    isStringConstant(binOp.getLeft()) and 
    isStringConstant(binOp.getRight())
  )
}

from StringLiteral targetString
where
  // Verify implicit concatenation exists
  exists(targetString.getAnImplicitlyConcatenatedPart()) and
  // Ensure string isn't explicitly parenthesized
  not targetString.isParenthesized() and
  // Check if string exists in list with other string constants
  exists(List containerList |
    // Confirm target string is in list
    containerList.getAnElt() = targetString and
    // Find another string constant in same list
    exists(Expr otherString |
      otherString != targetString and
      containerList.getAnElt() = otherString and
      isStringConstant(otherString)
    )
  )
select targetString, "Implicit string concatenation. Maybe missing a comma?"