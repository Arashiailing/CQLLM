/**
 * @name Misnamed function
 * @description Identifies functions that begin with uppercase letters, which violates Python naming conventions.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python  // Import Python library for analyzing Python source code

// Query to find functions with improper naming convention
from Function func
where
  // Ensure we only analyze functions defined in source code
  func.inSource() and
  
  // Check if function name starts with uppercase letter
  exists(string initialChar |
    initialChar = func.getName().prefix(1) and
    not initialChar = initialChar.toLowerCase()
  ) and
  
  // Exclude duplicate reports for functions with same name in same file
  not exists(Function otherFunc |
    otherFunc != func and
    otherFunc.getLocation().getFile() = func.getLocation().getFile() and
    exists(string initialChar |
      initialChar = otherFunc.getName().prefix(1) and
      not initialChar = initialChar.toLowerCase()
    )
  )
select func, "Function names should start in lowercase."