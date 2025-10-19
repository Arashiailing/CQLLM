/**
 * @name Function Naming Convention Violation
 * @description Detects Python functions violating PEP8 naming conventions by using uppercase letters at the start of their names.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Core Python analysis library for code inspection

// Predicate identifying functions with uppercase-initial names
predicate startsWithUppercase(Function func) {
  exists(string initialChar |
    initialChar = func.getName().prefix(1) and  // Extract first character of function name
    initialChar != initialChar.toLowerCase()   // Verify character is uppercase
  )
}

// Main query detecting PEP8 naming violations
from Function funcWithNamingIssue
where
  // Condition 1: Function must be in source code
  funcWithNamingIssue.inSource() and
  
  // Condition 2: Function name violates lowercase convention
  startsWithUppercase(funcWithNamingIssue) and
  
  // Condition 3: Ensure only one violation per file
  not exists(Function anotherFunc |
    anotherFunc != funcWithNamingIssue and  // Exclude same function
    anotherFunc.getLocation().getFile() = funcWithNamingIssue.getLocation().getFile() and  // Same file check
    startsWithUppercase(anotherFunc)  // Other function also violates naming
  )
select funcWithNamingIssue, "Function names should start with lowercase letters according to PEP8."