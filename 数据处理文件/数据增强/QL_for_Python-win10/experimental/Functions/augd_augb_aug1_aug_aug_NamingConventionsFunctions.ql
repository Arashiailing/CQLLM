/**
 * @name PEP8 Function Naming Convention Violation
 * @description Detects Python functions that don't adhere to PEP8 naming standards by starting with uppercase letters.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import Python analysis library for code inspection capabilities

from Function nonCompliantFunc
where
  // Verify the function is in source code (not in libraries)
  nonCompliantFunc.inSource() and
  // Check if function name starts with uppercase letter
  exists(string initialChar |
    initialChar = nonCompliantFunc.getName().prefix(1) and  // Get first character of function name
    not initialChar = initialChar.toLowerCase()  // Verify character is uppercase
  ) and
  // Exclude results when multiple functions in same file have same violation
  not exists(Function anotherFunc |
    anotherFunc != nonCompliantFunc and  // Ensure different function
    anotherFunc.getLocation().getFile() = nonCompliantFunc.getLocation().getFile() and  // Same file
    exists(string initialChar |
      initialChar = anotherFunc.getName().prefix(1) and  // Get first character
      not initialChar = initialChar.toLowerCase()  // Verify uppercase
    )
  )
select nonCompliantFunc, "Function names should start with lowercase letters according to PEP8."