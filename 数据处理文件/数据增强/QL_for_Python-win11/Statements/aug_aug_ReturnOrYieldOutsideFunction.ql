/**
 * @name Use of 'return' or 'yield' outside a function
 * @description Detects when 'return', 'yield', or 'yield from' statements are used outside function scope,
 *              which would cause a 'SyntaxError' at runtime in Python.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// Identify statements that are incorrectly placed outside function scope
from AstNode problematicStatement, string keywordType
where 
  // Verify the statement is not within any function's scope
  not exists(Function enclosingFunction | 
    problematicStatement.getScope() = enclosingFunction.getScope()
  ) and
  (
    // Case 1: Return statement used outside function
    problematicStatement instanceof Return and keywordType = "return"
    or
    // Case 2: Yield statement used outside function
    problematicStatement instanceof Yield and keywordType = "yield"
    or
    // Case 3: Yield from statement used outside function
    problematicStatement instanceof YieldFrom and keywordType = "yield from"
  )
// Report the problematic statement with appropriate error message
select problematicStatement, "'" + keywordType + "' is used outside a function."