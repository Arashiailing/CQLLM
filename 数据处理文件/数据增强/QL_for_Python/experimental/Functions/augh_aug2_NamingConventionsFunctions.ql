/**
 * @name Misnamed function
 * @description Functions with names starting with uppercase letters reduce code readability.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python  // Import Python library for analyzing Python source code

// Select functions violating naming conventions
from Function func
where
  // Ensure function is defined in source code
  func.inSource() and
  
  // Check if function name starts with uppercase letter
  exists(string initialChar |
    initialChar = func.getName().prefix(1) and  // Extract first character
    initialChar != initialChar.toLowerCase()   // Verify uppercase
  ) and
  
  // Exclude duplicate reports for same-named functions in same file
  not exists(Function otherFunc |
    otherFunc != func and  // Different function object
    otherFunc.getLocation().getFile() = func.getLocation().getFile() and  // Same file
    exists(string otherInitialChar |
      otherInitialChar = otherFunc.getName().prefix(1) and
      otherInitialChar != otherInitialChar.toLowerCase()  // Same naming violation
    )
  )
select func, "Function names should start in lowercase."  // Report violation