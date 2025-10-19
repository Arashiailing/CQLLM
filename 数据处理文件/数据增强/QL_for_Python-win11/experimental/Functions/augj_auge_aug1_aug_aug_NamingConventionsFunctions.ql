/**
 * @name Function Naming Convention Violation
 * @description Detects Python functions that violate PEP8 naming standards by starting with uppercase letters.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import Python analysis module for code inspection

// Query to find functions that violate PEP8 naming convention
from Function nonCompliantFunc
where
  // Ensure function is defined in source code
  nonCompliantFunc.inSource() and
  // Check if function name begins with uppercase letter
  exists(string initialChar |
    initialChar = nonCompliantFunc.getName().prefix(1) and
    not initialChar = initialChar.toLowerCase()
  ) and
  // Filter to report only one violation per file when multiple exist
  not exists(Function anotherFunc |
    anotherFunc != nonCompliantFunc and
    anotherFunc.getLocation().getFile() = nonCompliantFunc.getLocation().getFile() and
    exists(string initialChar |
      initialChar = anotherFunc.getName().prefix(1) and
      not initialChar = initialChar.toLowerCase()
    )
  )
select nonCompliantFunc, "Function names should start with lowercase letters according to PEP8."  // Display the violating function with an appropriate message