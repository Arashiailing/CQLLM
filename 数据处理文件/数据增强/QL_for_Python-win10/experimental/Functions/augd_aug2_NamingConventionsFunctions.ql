/**
 * @name Misnamed function
 * @description Identifies functions with uppercase initial letters, violating Python naming conventions.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * 
 * This query detects functions whose names begin with uppercase letters, which contradicts PEP8 guidelines.
 * The exclusion logic prevents duplicate reports within the same file by filtering out functions when
 * another uppercase-named function exists in the same file. Note: This may reduce reporting frequency
 * in files containing multiple such functions.
 */

import python

from Function func
where
  // Ensure function is source-defined (not library/built-in)
  func.inSource() and
  // Check if function name starts with uppercase letter
  exists(string initialChar |
    initialChar = func.getName().prefix(1) and
    not initialChar = initialChar.toLowerCase()
  ) and
  // Exclude functions if another uppercase-named function exists in same file
  not exists(Function otherFunc |
    otherFunc != func and
    otherFunc.getLocation().getFile() = func.getLocation().getFile() and
    exists(string otherInitialChar |
      otherInitialChar = otherFunc.getName().prefix(1) and
      not otherInitialChar = otherInitialChar.toLowerCase()
    )
  )
select func, "Function names should start in lowercase."