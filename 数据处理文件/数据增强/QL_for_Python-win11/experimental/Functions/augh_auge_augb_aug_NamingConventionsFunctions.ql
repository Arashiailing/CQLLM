/**
 * @name Misnamed function
 * @description Identifies functions that start with a capital letter and are the only such function in their file,
 *              which violates Python naming conventions.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

// Predicate to determine if a function's name begins with a capital letter
predicate startsWithCapitalLetter(Function func) {
  // Extract the first character of the function name and verify it's uppercase
  exists(string firstChar |
    firstChar = func.getName().prefix(1) and
    firstChar != firstChar.toLowerCase()
  )
}

// Find all functions that violate the naming convention
from Function targetFunc
where
  // Ensure the function is defined in source code
  targetFunc.inSource() and
  // Check if the function name starts with a capital letter
  startsWithCapitalLetter(targetFunc) and
  // Ensure this function is the only one in its file starting with a capital letter
  not exists(Function otherFunc |
    // Exclude the current function
    otherFunc != targetFunc and
    // Ensure they are in the same file
    otherFunc.getLocation().getFile() = targetFunc.getLocation().getFile() and
    // The other function also starts with a capital letter
    startsWithCapitalLetter(otherFunc)
  )
select targetFunc, "Function names should start in lowercase."