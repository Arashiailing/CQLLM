/**
 * @name Function with Uppercase Initial
 * @description Detects Python functions that begin with an uppercase letter, which contradicts the standard Python naming conventions.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @coding-standard Python PEP8 naming conventions
 */

import python  // Import Python library for analyzing Python code

// Helper predicate: Determines if a function's name starts with an uppercase letter
predicate beginsWithCapital(Function pyFunction) {
  exists(string initialChar |
    initialChar = pyFunction.getName().prefix(1) and  // Extract the first character of the function name
    not initialChar = initialChar.toLowerCase()  // Verify the first character is not lowercase
  )
}

// Query to find functions that violate naming conventions
from Function nonCompliantFunction
where
  // Ensure the function is defined in source code and starts with an uppercase letter
  nonCompliantFunction.inSource() and
  beginsWithCapital(nonCompliantFunction) and
  // Ensure no other function in the same file also starts with an uppercase letter
  not exists(Function otherFunction |
    otherFunction != nonCompliantFunction and  // Exclude the current function itself
    otherFunction.getLocation().getFile() = nonCompliantFunction.getLocation().getFile() and  // Ensure they are in the same file
    beginsWithCapital(otherFunction)  // The other function also starts with an uppercase letter
  )
select nonCompliantFunction, "Function names should start in lowercase."  // Output the function violating the naming convention