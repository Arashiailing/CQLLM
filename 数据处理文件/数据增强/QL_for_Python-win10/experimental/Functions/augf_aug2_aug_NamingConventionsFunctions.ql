/**
 * @name Misnamed function
 * @description Identifies functions with names starting with an uppercase letter, which can reduce code readability.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

// Define a predicate to determine if a function's name begins with an uppercase letter
predicate hasUppercaseStart(Function fn) {
  exists(string initialChar |
    initialChar = fn.getName().prefix(1) and  // Extract the first character of the function name
    initialChar = initialChar.toUpperCase()  // Verify if the first character is uppercase
  )
}

// Identify functions that match our criteria
from Function candidateFn
where
  // Ensure the function is present in the source code
  candidateFn.inSource() and
  // Function name starts with an uppercase letter
  hasUppercaseStart(candidateFn) and
  // Ensure this is the only function with an uppercase-starting name in its file
  not exists(Function similarFn |
    similarFn != candidateFn and  // Exclude other functions with the same name
    similarFn.getLocation().getFile() = candidateFn.getLocation().getFile() and  // Located in the same file
    hasUppercaseStart(similarFn)  // And also starts with an uppercase letter
  )
select candidateFn, "Function names should start in lowercase."  // Report these functions with a recommendation