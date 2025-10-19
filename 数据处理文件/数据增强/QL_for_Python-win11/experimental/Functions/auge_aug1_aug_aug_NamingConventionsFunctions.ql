/**
 * @name Function Naming Convention Violation
 * @description Identifies Python functions that do not adhere to PEP8 naming conventions by beginning with uppercase letters.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import Python analysis module for code inspection

// Predicate that determines if a function name begins with an uppercase character
predicate startsWithCapitalLetter(Function functionObj) {
  exists(string firstChar |
    firstChar = functionObj.getName().prefix(1) and  // Extract the first character of the function name
    not firstChar = firstChar.toLowerCase()  // Confirm the character is uppercase
  )
}

// Query to detect functions that violate the PEP8 naming convention
from Function violatingFunction
where
  violatingFunction.inSource() and  // Verify the function is defined in source code
  startsWithCapitalLetter(violatingFunction) and  // Confirm the function name starts with an uppercase letter
  // Exclude results when multiple functions in the same file commit the same violation
  not exists(Function otherFunction |
    otherFunction != violatingFunction and  // Ensure it's a different function
    otherFunction.getLocation().getFile() = violatingFunction.getLocation().getFile() and  // Both functions reside in the same file
    startsWithCapitalLetter(otherFunction)  // The other function also violates the naming convention
  )
select violatingFunction, "Function names should start with lowercase letters according to PEP8."  // Display the violating function with an appropriate message