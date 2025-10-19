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
 * Identifies string constants including implicitly concatenated strings.
 * Handles both direct literals and recursive binary operations between strings.
 */
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

from StringLiteral targetStr
where
  // Condition 1: Verify implicit concatenation exists and isn't parenthesized
  exists(targetStr.getAnImplicitlyConcatenatedPart()) and
  not targetStr.isParenthesized() and
  
  // Condition 2: Check if string exists in a list with other string constants
  exists(List containerList |
    // Confirm target string is in list
    containerList.getAnElt() = targetStr and
    
    // Find another string constant in same list
    exists(Expr otherStr |
      otherStr != targetStr and
      containerList.getAnElt() = otherStr and
      isStringConstant(otherStr)
    )
  )
select targetStr, "Implicit string concatenation. Maybe missing a comma?"