/**
 * @name Implicit string concatenation in a list
 * @description Detects implicit string concatenation in lists which may indicate missing commas
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
 * Determines whether an expression represents a string constant.
 * This includes both direct string literals and implicitly concatenated strings.
 * @param expr The expression to evaluate
 */
predicate isStringConstant(Expr expr) {
  // Base case: direct string literal
  expr instanceof StringLiteral
  // Recursive case: binary operation where both operands are string constants
  or 
  (
    isStringConstant(expr.(BinaryExpr).getLeft()) and 
    isStringConstant(expr.(BinaryExpr).getRight())
  )
}

/**
 * Identifies string literals with implicit concatenation within lists.
 * This pattern commonly indicates a missing comma between list elements.
 */
from StringLiteral strLit
where
  // Condition 1: The string literal contains implicit concatenation
  exists(strLit.getAnImplicitlyConcatenatedPart()) and
  // Condition 2: The string literal isn't parenthesized (which would make concatenation explicit)
  not strLit.isParenthesized() and
  // Condition 3: The string literal appears in a list containing another string constant
  exists(List containerList, Expr adjacentString |
    // The string literal is an element in the list
    containerList.getAnElt() = strLit and
    // The list contains another distinct string element
    containerList.getAnElt() = adjacentString and
    not strLit = adjacentString and
    // The adjacent element is also a string constant (literal or concatenated)
    isStringConstant(adjacentString)
  )
select strLit, "Implicit string concatenation. Maybe missing a comma?"