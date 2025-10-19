/**
 * @name Misnamed function
 * @description A function name starting with an uppercase letter reduces code readability.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

// Predicate to determine if a function name begins with an uppercase letter
predicate hasUppercaseInitial(Function targetFunction) {
  exists(string initialChar |
    initialChar = targetFunction.getName().prefix(1) and  // Extract the first character of the function name
    not initialChar = initialChar.toLowerCase()  // Check if the first character is not lowercase
  )
}

// Identify functions that start with an uppercase letter and are the only such function in their file
from Function targetFunction
where
  // Ensure the function is present in the source code
  targetFunction.inSource() and
  
  // Verify the function name starts with an uppercase letter
  hasUppercaseInitial(targetFunction) and
  
  // Ensure no other function in the same file starts with an uppercase letter
  not exists(Function otherFunction |
    otherFunction != targetFunction and  // Exclude the current function
    otherFunction.getLocation().getFile() = targetFunction.getLocation().getFile() and  // Same file check
    hasUppercaseInitial(otherFunction)  // Other function also starts with uppercase
  )
select targetFunction, "Function names should start in lowercase."  // Report these functions with a recommendation