/**
 * @name Function Naming Convention Violation
 * @description Identifies Python functions that begin with uppercase letters, which is inconsistent with PEP8 naming standards.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import the Python library for code analysis

// Predicate to determine if a function name starts with an uppercase letter
predicate hasUppercaseStart(Function fn) {
  exists(string firstChar |
    firstChar = fn.getName().prefix(1) and  // Extract the first character of the function name
    not firstChar = firstChar.toLowerCase()  // Check if the character is uppercase (not lowercase)
  )
}

// Select all functions that violate the naming convention
from Function fn
where
  fn.inSource() and  // The function must be in the source code
  hasUppercaseStart(fn) and  // The function name starts with an uppercase letter
  // Exclude reporting if there are multiple functions with the same issue in the same file
  not exists(Function anotherFunc |
    anotherFunc != fn and  // Not the same function
    anotherFunc.getLocation().getFile() = fn.getLocation().getFile() and  // In the same file
    hasUppercaseStart(anotherFunc)  // Also violates the naming convention
  )
select fn, "Function names should start with lowercase letters according to PEP8."  // Report the function with a suggestion