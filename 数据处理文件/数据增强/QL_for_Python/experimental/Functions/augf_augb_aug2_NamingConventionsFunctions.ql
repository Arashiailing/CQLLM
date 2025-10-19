/**
 * @name Misnamed function
 * @description Detects Python functions that begin with uppercase letters, which contradicts standard Python naming conventions.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python  // Import Python library for analyzing Python source code

// Predicate to check if a function name starts with an uppercase letter
predicate startsWithUppercase(Function fn) {
  exists(string firstChar |
    firstChar = fn.getName().prefix(1) and  // Get the first character of the function name
    firstChar != firstChar.toLowerCase()  // Confirm the character is uppercase
  )
}

// Main query to find functions with improper naming
from Function targetFunction
where
  targetFunction.inSource() and  // Ensure the function is defined in source code
  startsWithUppercase(targetFunction) and  // Verify the function starts with an uppercase letter
  not exists(Function otherFn |
    otherFn != targetFunction and  // Exclude the current function
    otherFn.getLocation().getFile() = targetFunction.getLocation().getFile() and  // Same file check
    startsWithUppercase(otherFn)  // Also starts with uppercase
  )
select targetFunction, "Function names should start in lowercase."  // Output the violation with a recommendation