/**
 * @name Misnamed function
 * @description Detects functions whose names begin with a capital letter, potentially impacting code readability.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

// Predicate to check if a function's name starts with a capital letter
predicate startsWithCapital(Function func) {
  exists(string firstLetter |
    firstLetter = func.getName().prefix(1) and  // Get the first character of the function name
    firstLetter = firstLetter.toUpperCase()  // Check if it's uppercase
  )
}

// Find functions that meet our naming criteria
from Function targetFunction
where
  // Verify the function is part of the source code
  targetFunction.inSource() and
  // Check if function name begins with a capital letter
  startsWithCapital(targetFunction) and
  // Ensure no other functions in the same file start with a capital letter
  not exists(Function otherFunction |
    otherFunction != targetFunction and  // Different function
    otherFunction.getLocation().getFile() = targetFunction.getLocation().getFile() and  // Same file
    startsWithCapital(otherFunction)  // Also starts with capital
  )
select targetFunction, "Function names should start in lowercase."  // Report with recommendation