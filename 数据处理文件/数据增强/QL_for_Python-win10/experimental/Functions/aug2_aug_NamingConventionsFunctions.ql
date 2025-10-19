/**
 * @name Misnamed function
 * @description Identifies functions with names starting with an uppercase letter, which can reduce code readability.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

// Define a predicate to check if a function name starts with an uppercase letter
predicate startsWithUppercase(Function fn) {
  exists(string firstChar |
    firstChar = fn.getName().prefix(1) and  // Extract the first character of the function name
    firstChar = firstChar.toUpperCase()  // Check if the first character is uppercase
  )
}

// Select functions that meet the specified criteria
from Function targetFn
where
  targetFn.inSource() and  // Ensure the function is present in the source code
  startsWithUppercase(targetFn) and  // Function name starts with an uppercase letter
  not exists(Function otherFn |
    otherFn != targetFn and  // Exclude other functions with the same name
    otherFn.getLocation().getFile() = targetFn.getLocation().getFile() and  // Located in the same file
    startsWithUppercase(otherFn)  // And also starts with an uppercase letter
  )
select targetFn, "Function names should start in lowercase."  // Report these functions with a recommendation