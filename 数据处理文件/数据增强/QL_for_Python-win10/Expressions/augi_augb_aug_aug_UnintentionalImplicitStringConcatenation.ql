/**
 * @name Implicit string concatenation in a list
 * @description Identifies string literals that undergo implicit concatenation within list structures.
 *              Such patterns often indicate missing commas between list elements and can compromise
 *              code readability and maintainability.
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
 * Determines whether an expression represents a string constant, accounting for
 * implicitly concatenated strings formed through adjacent string literals.
 * This predicate handles both primitive string literals and complex expressions
 * resulting from recursive concatenation operations.
 */
predicate isStringConstant(Expr evaluatedExpr) {
  // Base case: Primitive string literal
  evaluatedExpr instanceof StringLiteral
  // Recursive case: Binary concatenation operation between string constants
  or 
  exists(BinaryExpr concatenationOp | 
    concatenationOp = evaluatedExpr and 
    isStringConstant(concatenationOp.getLeft()) and 
    isStringConstant(concatenationOp.getRight())
  )
}

from StringLiteral targetString
where
  // Verification of implicit concatenation without explicit grouping
  exists(targetString.getAnImplicitlyConcatenatedPart()) and
  not targetString.isParenthesized() and
  
  // Contextual analysis: String appears within a list containing other string constants
  exists(List containingList |
    // Establish containment relationship
    containingList.getAnElt() = targetString and
    
    // Identify co-located string constant within the same list structure
    exists(Expr adjacentString |
      adjacentString != targetString and
      containingList.getAnElt() = adjacentString and
      isStringConstant(adjacentString)
    )
  )
select targetString, "Implicit string concatenation. Maybe missing a comma?"