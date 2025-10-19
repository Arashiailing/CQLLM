/**
 * @name Function Naming Convention Violation
 * @description Identifies Python functions that begin with uppercase letters,
 *              which contradicts PEP8 guidelines requiring function names to start with lowercase.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import the Python library for code analysis

// Find functions that violate PEP8 naming convention
from Function violatingFunction
where
  // Verify the function is part of the source code
  violatingFunction.inSource() and
  
  // Extract and check the first character of function name
  exists(string startingLetter |
    startingLetter = violatingFunction.getName().prefix(1) and  // Get first character
    startingLetter != startingLetter.toLowerCase()             // Confirm it's uppercase
  ) and
  
  // Ensure only the first violation per file is reported to avoid duplicates
  not exists(Function previousViolation |
    previousViolation != violatingFunction and  // Different function instance
    previousViolation.getLocation().getFile() = violatingFunction.getLocation().getFile() and  // Same source file
    exists(string previousStartingLetter |
      previousStartingLetter = previousViolation.getName().prefix(1) and  // Extract first character
      previousStartingLetter != previousStartingLetter.toLowerCase()      // Verify uppercase violation
    )
  )
select violatingFunction, "Function names should start with lowercase letters according to PEP8."  // Output violation with recommendation