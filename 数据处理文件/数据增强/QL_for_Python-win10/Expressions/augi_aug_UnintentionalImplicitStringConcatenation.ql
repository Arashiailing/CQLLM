/**
 * @name Implicit string concatenation in a list
 * @description Identifies implicit string concatenation within lists that may indicate missing commas
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

// Predicate to recognize string constants including implicitly concatenated components
predicate isStringConstant(Expr expression) {
  // Base case: Direct string literal
  expression instanceof StringLiteral
  // Recursive case: Binary operation with string constant operands
  or
  isStringConstant(expression.(BinaryExpr).getLeft()) and isStringConstant(expression.(BinaryExpr).getRight())
}

// Main query targeting string literals in list contexts
from StringLiteral stringLiteral
where
  // Condition 1: String exists in a list with other string constants
  exists(List parentList, Expr anotherString |
    // Verify distinct elements within same list
    stringLiteral != anotherString and
    parentList.getAnElt() = stringLiteral and
    parentList.getAnElt() = anotherString and
    isStringConstant(anotherString)
  ) and
  // Condition 2: String contains implicit concatenation components
  exists(stringLiteral.getAnImplicitlyConcatenatedPart()) and
  // Condition 3: String lacks explicit parenthesization
  not stringLiteral.isParenthesized()
select stringLiteral, "Implicit string concatenation detected. Consider adding missing comma?"