/**
 * @name Misnamed function
 * @description Detects functions that begin with a capital letter, which goes against Python naming conventions and can negatively impact code readability.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

/**
 * Determines if a function's name starts with an uppercase letter.
 * This is accomplished by taking the first character of the function's name
 * and checking if it differs from its lowercase version, indicating it's uppercase.
 */
predicate hasCapitalizedName(Function funcToCheck) {
  exists(string firstChar |
    firstChar = funcToCheck.getName().prefix(1) and  // Get the first character of the function name
    not firstChar = firstChar.toLowerCase()  // Check if the first character is uppercase
  )
}

// Locate functions with capitalized names that are the only ones with this characteristic in their source file
from Function targetFunction
where
  // Basic conditions for the function to be examined
  targetFunction.inSource() and
  hasCapitalizedName(targetFunction) and
  // Uniqueness condition: no other function in the same file has a capitalized name
  not exists(Function anotherFunction |
    anotherFunction.getLocation().getFile() = targetFunction.getLocation().getFile() and  // Restrict to the same file
    anotherFunction != targetFunction and  // Exclude the function being examined
    hasCapitalizedName(anotherFunction)  // The other function also has a capitalized name
  )
select targetFunction, "Function names should start in lowercase."  // Flag violations of the naming convention