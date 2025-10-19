/**
 * @name Misnamed function
 * @description Identifies functions whose names begin with uppercase letters, which violates Python naming conventions.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python  // Import Python library for analyzing Python source code

from Function func
where
  // Ensure the function is defined in source code
  func.inSource() and
  // Check if the function name starts with an uppercase letter
  exists(string initialChar |
    initialChar = func.getName().prefix(1) and  // Extract the first character of the function name
    not initialChar = initialChar.toLowerCase()  // Verify that the character is not lowercase
  ) and
  // Exclude cases where there are multiple functions with the same name in the same file
  not exists(Function otherFunc |
    otherFunc != func and  // Exclude other functions with the same name
    otherFunc.getLocation().getFile() = func.getLocation().getFile() and  // In the same file
    // Check if the other function name also starts with an uppercase letter
    exists(string otherInitialChar |
      otherInitialChar = otherFunc.getName().prefix(1) and
      not otherInitialChar = otherInitialChar.toLowerCase()
    )
  )
select func, "Function names should start in lowercase."  // Report the function with a recommendation