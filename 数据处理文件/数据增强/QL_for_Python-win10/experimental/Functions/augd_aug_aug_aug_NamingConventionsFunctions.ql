/**
 * @name Function Naming Convention Violation
 * @description Identifies Python functions that begin with uppercase letters,
 *              which contradicts PEP8 guidelines for function naming.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import Python analysis library

// Find functions that violate PEP8 naming conventions
from Function violatingFunction
where
  // Verify the function is part of the source code
  violatingFunction.inSource() and
  
  // Determine if the function starts with an uppercase letter
  (exists(string startingChar |
    startingChar = violatingFunction.getName().prefix(1) and  // Get first character
    startingChar != startingChar.toLowerCase()  // Check if it's uppercase
  )) and
  
  // Ensure only the first violation per file is reported to avoid duplicates
  not exists(Function duplicateFunction |
    duplicateFunction != violatingFunction and  // Different function
    duplicateFunction.getLocation().getFile() = violatingFunction.getLocation().getFile() and  // Same file
    exists(string duplicateStartingChar |
      duplicateStartingChar = duplicateFunction.getName().prefix(1) and  // Get first character
      duplicateStartingChar != duplicateStartingChar.toLowerCase()  // Check if it's uppercase
    )
  )
select violatingFunction, "Function names should start with lowercase letters according to PEP8."  // Output violation with recommendation