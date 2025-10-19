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
 * Determines if an expression represents a string constant value,
 * accounting for both direct literals and implicitly concatenated strings.
 * This includes recursive binary operations between string constants.
 */
predicate isStringConstant(Expr strExpr) {
  // Base case: Direct string literal
  strExpr instanceof StringLiteral
  // Recursive case: Binary operation combining string constants
  or 
  exists(BinaryExpr binOp | 
    binOp = strExpr and 
    isStringConstant(binOp.getLeft()) and 
    isStringConstant(binOp.getRight())
  )
}

from StringLiteral strLit
where
  // Condition 1: Identify non-parenthesized strings with implicit concatenation
  exists(strLit.getAnImplicitlyConcatenatedPart()) and
  not strLit.isParenthesized() and
  
  // Condition 2: Verify presence in a list containing other string constants
  exists(List containerList, Expr adjacentStr |
    // Current string is part of the list
    containerList.getAnElt() = strLit and
    // Another string constant exists in the same list
    containerList.getAnElt() = adjacentStr and
    adjacentStr != strLit and
    isStringConstant(adjacentStr)
  )
select strLit, "Implicit string concatenation. Maybe missing a comma?"