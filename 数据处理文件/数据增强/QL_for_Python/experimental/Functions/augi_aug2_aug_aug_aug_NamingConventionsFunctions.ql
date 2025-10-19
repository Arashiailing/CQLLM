/**
 * @name Function Naming Convention Violation
 * @description Identifies Python functions that begin with uppercase letters,
 *              which contradicts the PEP8 naming conventions for function names.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import the Python library for code analysis

// Identify functions that violate PEP8 naming conventions
from Function violatingFunction
where
  // Ensure the function is part of the source code
  violatingFunction.inSource() and
  
  // Check if the function name starts with an uppercase letter
  exists(string initialChar |
    initialChar = violatingFunction.getName().prefix(1) and  // Extract the first character
    initialChar != initialChar.toLowerCase()                // Confirm it's uppercase
  ) and
  
  // Report only the first violation per file to avoid duplicate alerts
  not exists(Function otherViolatingFunction |
    // Ensure it's a different function in the same file
    otherViolatingFunction != violatingFunction and
    otherViolatingFunction.getLocation().getFile() = violatingFunction.getLocation().getFile() and
    
    // Check if the other function also violates the naming convention
    exists(string otherInitialChar |
      otherInitialChar = otherViolatingFunction.getName().prefix(1) and
      otherInitialChar != otherInitialChar.toLowerCase()
    )
  )
select violatingFunction, "Function names should start with lowercase letters according to PEP8."  // Report the violation with a suggestion