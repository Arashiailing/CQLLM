/**
 * @name Function Naming Convention Violation
 * @description Identifies Python functions that violate PEP8 naming conventions by using uppercase letters at the beginning of their names.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import Python analysis library to enable code inspection capabilities

// Helper predicate to determine if a function's name begins with an uppercase letter
predicate hasCapitalizedName(Function functionObj) {
  exists(string firstChar |
    firstChar = functionObj.getName().prefix(1) and  // Extract the first character of the function name
    not firstChar = firstChar.toLowerCase()  // Confirm the character is uppercase
  )
}

// Main query to identify functions that don't follow the naming convention
from Function violatingFunction
where
  // Ensure the function is part of the source code
  violatingFunction.inSource() and
  // Check if the function name begins with an uppercase letter
  hasCapitalizedName(violatingFunction) and
  // Filter out results when multiple functions in the same file have the same violation
  not exists(Function otherFunction |
    otherFunction != violatingFunction and  // Ensure it's not the same function
    otherFunction.getLocation().getFile() = violatingFunction.getLocation().getFile() and  // Both functions are in the same file
    hasCapitalizedName(otherFunction)  // The other function also violates the naming convention
  )
select violatingFunction, "Function names should start with lowercase letters according to PEP8."