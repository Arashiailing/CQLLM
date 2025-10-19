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
 * Checks whether a function's name begins with an uppercase letter.
 * The verification involves extracting the initial character of the function name 
 * and comparing it with its lowercase equivalent to confirm it's uppercase.
 */
predicate hasCapitalizedName(Function funcToExamine) {
  exists(string initialChar |
    initialChar = funcToExamine.getName().prefix(1) and  // Extract the first character of the function name
    not initialChar = initialChar.toLowerCase()  // Verify if the first character is uppercase
  )
}

// Identify functions with capitalized names that are unique within their source file
from Function functionUnderTest
where
  functionUnderTest.inSource() and  // Ensure the function exists in source code
  hasCapitalizedName(functionUnderTest) and  // Function name starts with a capital letter
  // Verify no other function in the same file has a capitalized name
  not exists(Function otherFunction |
    otherFunction.getLocation().getFile() = functionUnderTest.getLocation().getFile() and  // Same file constraint
    otherFunction != functionUnderTest and  // Exclude the current function
    hasCapitalizedName(otherFunction)  // Other function also has capitalized name
  )
select functionUnderTest, "Function names should start in lowercase."  // Report violations with naming convention message