/**
 * @name Use of 'return' or 'yield' outside a function
 * @description Detects syntactically invalid placements of 'return', 'yield', or 'yield from' 
 *              statements outside function boundaries, which would cause 'SyntaxError' during 
 *              Python execution.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// Identify statements illegally positioned outside function definitions
from AstNode misplacedStmt, string keyword
where 
  // Verify the statement resides outside any function's lexical scope
  not exists(Function containingFunction | 
    misplacedStmt.getScope() = containingFunction.getScope()
  ) and
  // Classify the specific type of invalid statement
  (
    // Handle 'return' statement misuse
    misplacedStmt instanceof Return and keyword = "return"
    or
    // Handle 'yield' statement misuse
    misplacedStmt instanceof Yield and keyword = "yield"
    or
    // Handle 'yield from' statement misuse
    misplacedStmt instanceof YieldFrom and keyword = "yield from"
  )
// Generate alert with contextual error message
select misplacedStmt, "Invalid use of '" + keyword + "' outside function scope."