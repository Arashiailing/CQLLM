/**
 * @name Misnamed function
 * @description Identifies Python functions that violate the standard naming convention by beginning with uppercase letters.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python  // Import Python library for analyzing Python source code

// Helper predicate to check if a function name starts with an uppercase letter
predicate startsWithUppercase(Function func) {
  exists(string initialChar |
    initialChar = func.getName().prefix(1) and  // Extract the first character of the function name
    initialChar != initialChar.toLowerCase()   // Verify the character is uppercase
  )
}

// Main query to detect functions violating Python naming conventions
from Function violatingFunction
where
  // Ensure the function is defined in source code
  violatingFunction.inSource() and  
  // Check if the function name starts with an uppercase letter
  startsWithUppercase(violatingFunction) and  
  // Exclude files that contain multiple functions with uppercase-initial names
  not exists(Function otherFunction |
    otherFunction != violatingFunction and  // Exclude the current function
    otherFunction.getLocation().getFile() = violatingFunction.getLocation().getFile() and  // Same file check
    startsWithUppercase(otherFunction)  // Also has uppercase-initial naming
  )
select violatingFunction, "Function names should start in lowercase."  // Report violation with recommendation