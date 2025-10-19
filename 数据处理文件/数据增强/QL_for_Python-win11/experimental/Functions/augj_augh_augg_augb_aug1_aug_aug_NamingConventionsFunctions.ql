/**
 * @name PEP8 Function Naming Convention Check
 * @description Detects Python functions that do not adhere to PEP8 naming guidelines by starting with uppercase letters.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import Python analysis library to enable code inspection capabilities

// Main query to identify functions that don't follow the naming convention
from Function misnamedFunction
where
  // Ensure the function is part of the source code
  misnamedFunction.inSource() and
  // Check if the function name begins with an uppercase letter
  exists(string initialChar |
    initialChar = misnamedFunction.getName().prefix(1) and  // Extract the first character of the function name
    not initialChar = initialChar.toLowerCase()  // Confirm the character is uppercase
  ) and
  // Filter out results when multiple functions in the same file have the same violation
  not exists(Function similarFunction |
    similarFunction != misnamedFunction and  // Ensure it's not the same function
    similarFunction.getLocation().getFile() = misnamedFunction.getLocation().getFile() and  // Both functions are in the same file
    exists(string similarInitialChar |
      similarInitialChar = similarFunction.getName().prefix(1) and
      not similarInitialChar = similarInitialChar.toLowerCase()
    )  // The other function also violates the naming convention
  )
select misnamedFunction, "Function names should start with lowercase letters according to PEP8."