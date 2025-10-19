/**
 * @name Misnamed function
 * @description Functions with names starting with uppercase letters reduce code readability.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python  // Import Python library for analyzing Python source code

// Predicate to check if a function name starts with an uppercase letter
predicate isMisnamedFunction(Function targetFunction) {
  exists(string firstLetter |
    firstLetter = targetFunction.getName().prefix(1) and  // Extract the first character of the function name
    not firstLetter = firstLetter.toLowerCase()  // Verify that the character is not lowercase
  )
}

// Select all functions that meet our criteria
from Function targetFunction
where
  targetFunction.inSource() and  // Ensure the function is defined in source code
  isMisnamedFunction(targetFunction) and  // Check if the function name starts with uppercase
  not exists(Function duplicateFunction |
    duplicateFunction != targetFunction and  // Exclude other functions with the same name
    duplicateFunction.getLocation().getFile() = targetFunction.getLocation().getFile() and  // In the same file
    isMisnamedFunction(duplicateFunction)  // And also starts with uppercase
  )
select targetFunction, "Function names should start in lowercase."  // Report the function with a recommendation