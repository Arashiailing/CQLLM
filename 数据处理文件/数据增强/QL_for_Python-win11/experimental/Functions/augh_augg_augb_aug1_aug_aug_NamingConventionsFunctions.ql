/**
 * @name Function Naming Convention Violation
 * @description Identifies Python functions that violate PEP8 naming conventions by using uppercase initial letters.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import Python analysis library to enable code inspection capabilities

// Main query to identify functions that don't follow the naming convention
from Function violatingFunction
where
  // Ensure the function is part of the source code
  violatingFunction.inSource() and
  // Check if the function name begins with an uppercase letter
  exists(string firstChar |
    firstChar = violatingFunction.getName().prefix(1) and  // Extract the first character of the function name
    not firstChar = firstChar.toLowerCase()  // Confirm the character is uppercase
  ) and
  // Filter out results when multiple functions in the same file have the same violation
  not exists(Function otherFunction |
    otherFunction != violatingFunction and  // Ensure it's not the same function
    otherFunction.getLocation().getFile() = violatingFunction.getLocation().getFile() and  // Both functions are in the same file
    exists(string otherFirstChar |
      otherFirstChar = otherFunction.getName().prefix(1) and
      not otherFirstChar = otherFirstChar.toLowerCase()
    )  // The other function also violates the naming convention
  )
select violatingFunction, "Function names should start with lowercase letters according to PEP8."