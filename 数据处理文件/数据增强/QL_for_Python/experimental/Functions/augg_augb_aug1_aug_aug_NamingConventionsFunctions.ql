/**
 * @name Function Naming Convention Violation
 * @description Detects Python functions that violate PEP8 naming conventions by starting with uppercase letters.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import Python analysis library to enable code inspection capabilities

// Main query to identify functions that don't follow the naming convention
from Function nonCompliantFunc
where
  // Ensure the function is part of the source code
  nonCompliantFunc.inSource() and
  // Check if the function name begins with an uppercase letter
  exists(string initialChar |
    initialChar = nonCompliantFunc.getName().prefix(1) and  // Extract the first character of the function name
    not initialChar = initialChar.toLowerCase()  // Confirm the character is uppercase
  ) and
  // Filter out results when multiple functions in the same file have the same violation
  not exists(Function anotherFunc |
    anotherFunc != nonCompliantFunc and  // Ensure it's not the same function
    anotherFunc.getLocation().getFile() = nonCompliantFunc.getLocation().getFile() and  // Both functions are in the same file
    exists(string anotherInitialChar |
      anotherInitialChar = anotherFunc.getName().prefix(1) and
      not anotherInitialChar = anotherInitialChar.toLowerCase()
    )  // The other function also violates the naming convention
  )
select nonCompliantFunc, "Function names should start with lowercase letters according to PEP8."