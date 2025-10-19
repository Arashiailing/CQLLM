/**
 * @name Function Naming Convention Violation
 * @description Identifies Python functions that violate PEP8 naming conventions by starting with uppercase letters
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Core Python analysis library for code inspection

// Predicate to detect functions with uppercase-initial names
predicate hasUppercaseInitial(Function func) {
  exists(string firstChar |
    firstChar = func.getName().prefix(1) and  // Extract first character of function name
    firstChar != firstChar.toLowerCase()   // Verify character is uppercase
  )
}

// Main query to identify PEP8 naming violations
from Function func
where
  // Condition 1: Function must be in source code
  func.inSource() and
  
  // Condition 2: Function name violates lowercase convention
  hasUppercaseInitial(func) and
  
  // Condition 3: Ensure only one violation per file
  not exists(Function otherFunc |
    otherFunc != func and  // Exclude same function
    otherFunc.getLocation().getFile() = func.getLocation().getFile() and  // Same file check
    hasUppercaseInitial(otherFunc)  // Other function also violates naming
  )
select func, "Function names should start with lowercase letters according to PEP8."