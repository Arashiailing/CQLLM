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
 * Recursively determines if an expression is a string constant.
 * This includes both direct string literals and implicitly concatenated strings.
 * @param expression The expression to check
 */
predicate isStringConstant(Expr expression) {
  // Base case: expression is a direct string literal
  expression instanceof StringLiteral
  // Recursive case: expression is a binary operation where both operands are string constants
  or 
  isStringConstant(expression.(BinaryExpr).getLeft()) and 
  isStringConstant(expression.(BinaryExpr).getRight())
}

/**
 * Main query to find string literals with implicit concatenation in lists.
 * This pattern often indicates a missing comma between list elements.
 */
from StringLiteral stringLiteral
where
  // Condition 1: The string literal has implicit concatenation
  exists(stringLiteral.getAnImplicitlyConcatenatedPart()) and
  // Condition 2: The string literal is not parenthesized (which would make concatenation explicit)
  not stringLiteral.isParenthesized() and
  // Condition 3: The string literal is in a list with at least one other string constant
  exists(List parentList, Expr siblingString |
    // The string literal is an element of the list
    parentList.getAnElt() = stringLiteral and
    // The list contains another string element (different from the current one)
    parentList.getAnElt() = siblingString and
    not stringLiteral = siblingString and
    // The other element is also a string constant (literal or concatenated)
    isStringConstant(siblingString)
  )
select stringLiteral, "Implicit string concatenation. Maybe missing a comma?"