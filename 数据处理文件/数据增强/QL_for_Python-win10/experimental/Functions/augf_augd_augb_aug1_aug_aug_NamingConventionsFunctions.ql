/**
 * @name PEP8 Function Naming Convention Violation
 * @description Identifies Python functions that violate PEP8 naming conventions by using uppercase initial letters.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import Python analysis library for code inspection capabilities

from Function violatingFunction
where
  // Ensure the function is part of the source code (not in libraries)
  violatingFunction.inSource() and
  
  // Check if function name starts with an uppercase letter
  exists(string firstChar |
    firstChar = violatingFunction.getName().prefix(1) and  // Extract the first character
    not firstChar = firstChar.toLowerCase()  // Verify the character is uppercase
  ) and
  
  // Limit to one violation per file to avoid redundant warnings
  not exists(Function otherFunction |
    otherFunction != violatingFunction and  // Different function
    otherFunction.getLocation().getFile() = violatingFunction.getLocation().getFile() and  // Same file
    // Apply the same uppercase check to other functions
    exists(string firstChar |
      firstChar = otherFunction.getName().prefix(1) and  // Extract first character
      not firstChar = firstChar.toLowerCase()  // Verify uppercase
    )
  )
select violatingFunction, "Function names should start with lowercase letters according to PEP8."