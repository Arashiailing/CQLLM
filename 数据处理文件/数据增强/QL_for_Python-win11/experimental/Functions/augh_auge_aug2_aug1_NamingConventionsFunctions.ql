/**
 * @name Function with Uppercase Initial
 * @description Identifies Python functions starting with uppercase letters, violating PEP8 naming conventions that require lowercase function names.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @coding-standard Python PEP8 naming conventions
 */

import python

from Function misnamedFunc
where
  // Ensure function is source code and starts with uppercase letter
  misnamedFunc.inSource() and
  exists(string firstChar |
    firstChar = misnamedFunc.getName().prefix(1) and
    not firstChar = firstChar.toLowerCase()
  ) and
  // Verify no other uppercase-starting functions exist in the same file
  not exists(Function anotherFunc |
    anotherFunc != misnamedFunc and
    anotherFunc.getLocation().getFile() = misnamedFunc.getLocation().getFile() and
    exists(string otherFirstChar |
      otherFirstChar = anotherFunc.getName().prefix(1) and
      not otherFirstChar = otherFirstChar.toLowerCase()
    )
  )
select misnamedFunc, "Function names should start in lowercase."