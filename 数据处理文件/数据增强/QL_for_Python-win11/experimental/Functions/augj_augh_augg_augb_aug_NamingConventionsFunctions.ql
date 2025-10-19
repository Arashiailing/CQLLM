/**
 * @name Misnamed function
 * @description Detects functions that begin with a capital letter, which contradicts Python naming conventions and can negatively impact code readability.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

/**
 * Checks whether a function's name starts with an uppercase letter.
 * The verification is done by taking the initial character of the function name and comparing it with its lowercase version.
 */
predicate hasCapitalizedName(Function targetFunction) {
  exists(string initialChar |
    initialChar = targetFunction.getName().prefix(1) and  // Get the first character of the function name
    not initialChar = initialChar.toLowerCase()  // Confirm the initial character is uppercase
  )
}

// Identify functions that begin with a capital letter and are the only ones with this naming pattern in their respective files
from Function targetFunc
where
  targetFunc.inSource() and  // Verify the function is part of the source code
  hasCapitalizedName(targetFunc) and  // The function name starts with a capital letter
  // Ensure no other function in the same file has a capital letter as its initial character
  not exists(Function otherFunction |
    otherFunction.getLocation().getFile() = targetFunc.getLocation().getFile() and  // Both functions must be in the same file
    otherFunction != targetFunc and  // Exclude the current function from the comparison
    hasCapitalizedName(otherFunction)  // The other function also starts with a capital letter
  )
select targetFunc, "Function names should start in lowercase."  // Report these functions with a message indicating the naming convention