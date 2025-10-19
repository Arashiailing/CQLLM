/**
 * @name Misnamed function
 * @description Identifies functions that start with a capital letter, which violates Python naming conventions and reduces code readability.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

/**
 * Determines if a function name begins with an uppercase letter.
 * This is verified by extracting the first character of the function name and checking if it differs from its lowercase equivalent.
 */
predicate hasCapitalizedName(Function functionToCheck) {
  exists(string firstChar |
    firstChar = functionToCheck.getName().prefix(1) and  // Extract the first character of the function name
    not firstChar = firstChar.toLowerCase()  // Verify if the first character is uppercase
  )
}

// Find all functions that start with a capital letter and are unique within their file
from Function func
where
  func.inSource() and  // Ensure the function is present in the source code
  hasCapitalizedName(func) and  // Function name starts with a capital letter
  // Check that no other function in the same file starts with a capital letter
  not exists(Function anotherFunction |
    anotherFunction.getLocation().getFile() = func.getLocation().getFile() and  // Ensure they are in the same file
    anotherFunction != func and  // Exclude the current function itself
    hasCapitalizedName(anotherFunction)  // Other function also starts with a capital letter
  )
select func, "Function names should start in lowercase."  // Report these functions with a message indicating function names should start with lowercase