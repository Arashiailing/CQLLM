/**
 * @name Misnamed function
 * @description Identifies functions with uppercase initial characters that reduce code readability.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

// Predicate to check if a function name starts with an uppercase letter
predicate starts_with_uppercase(Function targetFunction) {
  exists(string initialChar |
    initialChar = targetFunction.getName().prefix(1) and  // Extract first character of function name
    initialChar != initialChar.toLowerCase()  // Verify character remains uppercase when converted
  )
}

// Identify source functions with uppercase names that are unique in their file
from Function targetFunction
where
  targetFunction.inSource() and  // Ensure function exists in source code
  starts_with_uppercase(targetFunction) and  // Check for uppercase initial character
  not exists(Function otherFunction |
    otherFunction != targetFunction and  // Exclude the same function instance
    otherFunction.getLocation().getFile() = targetFunction.getLocation().getFile() and  // Same file constraint
    starts_with_uppercase(otherFunction)  // Other function also has uppercase name
  )
select targetFunction, "Function names should start in lowercase."  // Report findings with recommendation