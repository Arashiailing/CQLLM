/**
 * @name Misnamed function
 * @description Detects functions that begin with a capital letter and are the only such function in their file,
 *              which contradicts Python naming conventions for functions.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

// Helper predicate to check if a function's name starts with an uppercase letter
predicate hasCapitalizedName(Function func) {
  // Extract the initial character and verify it's uppercase
  exists(string initialChar |
    initialChar = func.getName().prefix(1) and
    initialChar.toUpperCase() = initialChar
  )
}

// Identify functions violating naming conventions
from Function candidateFunc
where
  // Verify the function is part of the source code
  candidateFunc.inSource() and
  // Check the function name starts with a capital letter
  hasCapitalizedName(candidateFunc) and
  // Ensure no other function in the same file starts with a capital letter
  count(Function peerFunc |
    peerFunc.getLocation().getFile() = candidateFunc.getLocation().getFile() and
    hasCapitalizedName(peerFunc)
  ) = 1
select candidateFunc, "Function names should start in lowercase."