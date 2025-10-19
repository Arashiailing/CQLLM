/**
 * @name Function Naming Convention Violation
 * @description Detects Python functions that start with uppercase letters,
 *              which goes against PEP8 naming conventions for function names.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import the Python library for code analysis

// Find functions that violate PEP8 naming convention
from Function func
where
  // Ensure the function is part of the source code
  func.inSource() and
  
  // Check if the function name starts with an uppercase letter
  func.getName().prefix(1).toUpperCase() = func.getName().prefix(1) and
  
  // Avoid duplicate reports: only report one violation per file
  not exists(Function anotherFunc |
    anotherFunc != func and  // Different function
    anotherFunc.getLocation().getFile() = func.getLocation().getFile() and  // Same file
    anotherFunc.getName().prefix(1).toUpperCase() = anotherFunc.getName().prefix(1)  // Also violates naming
  )
select func, "Function names should start with lowercase letters according to PEP8."  // Report violation with suggestion