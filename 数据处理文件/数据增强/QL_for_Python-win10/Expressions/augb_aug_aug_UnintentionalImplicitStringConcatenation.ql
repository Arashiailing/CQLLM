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
predicate isStringConstant(Expr stringExpr) {
  // Base case: Direct string literal
  stringExpr instanceof StringLiteral
  // Recursive case: Binary operation between string constants
  or 
  exists(BinaryExpr binaryOp | 
    binaryOp = stringExpr and 
    isStringConstant(binaryOp.getLeft()) and 
    isStringConstant(binaryOp.getRight())
  )
}

from StringLiteral stringLiteral
where
  // Condition 1: Verify implicit concatenation exists and isn't parenthesized
  exists(stringLiteral.getAnImplicitlyConcatenatedPart()) and
  not stringLiteral.isParenthesized() and
  
  // Condition 2: Check if string exists in a list with other string constants
  exists(List parentList |
    // Confirm target string is in list
    parentList.getAnElt() = stringLiteral and
    
    // Find another string constant in same list
    exists(Expr anotherString |
      anotherString != stringLiteral and
      parentList.getAnElt() = anotherString and
      isStringConstant(anotherString)
    )
  )
select stringLiteral, "Implicit string concatenation. Maybe missing a comma?"