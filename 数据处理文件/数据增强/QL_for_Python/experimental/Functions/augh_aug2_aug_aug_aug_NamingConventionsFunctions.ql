/**
 * @name PEP8 Function Naming Convention Violation
 * @description Detects Python functions with names starting with uppercase letters,
 *              which violates PEP8 naming conventions for functions.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import the Python library for code analysis

// Identify functions that violate PEP8 naming conventions
from Function func
where
  // The function must be part of the source code
  func.inSource() and
  
  // The function name must start with an uppercase letter
  exists(string initialChar |
    initialChar = func.getName().prefix(1) and
    initialChar != initialChar.toLowerCase()
  ) and
  
  // There should be no other violating function in the same file
  not exists(Function otherFunc |
    otherFunc != func and
    otherFunc.getLocation().getFile() = func.getLocation().getFile() and
    exists(string otherInitialChar |
      otherInitialChar = otherFunc.getName().prefix(1) and
      otherInitialChar != otherInitialChar.toLowerCase()
    )
  )
select func, "Function names should start with lowercase letters according to PEP8."  // Report the violation with a suggestion