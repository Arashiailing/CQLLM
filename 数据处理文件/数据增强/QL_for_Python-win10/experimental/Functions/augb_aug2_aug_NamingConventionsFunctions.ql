/**
 * @name Misnamed function
 * @description Identifies functions with names starting with an uppercase letter, which can reduce code readability.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

// Predicate to determine if a function name begins with an uppercase letter
predicate hasUppercaseInitial(Function func) {
  exists(string initialChar |
    initialChar = func.getName().prefix(1) and  // Extract the first character of the function name
    initialChar = initialChar.toUpperCase()  // Verify the initial character is uppercase
  )
}

// Query to identify functions violating naming conventions
from Function func
where
  func.inSource() and  // Ensure the function is defined in source code
  hasUppercaseInitial(func) and  // Function name starts with uppercase letter
  not exists(Function otherFunc |
    otherFunc != func and  // Exclude other functions with same name
    otherFunc.getLocation().getFile() = func.getLocation().getFile() and  // Located in same file
    hasUppercaseInitial(otherFunc)  // Also has uppercase initial
  )
select func, "Function names should start in lowercase."  // Report violation with recommendation