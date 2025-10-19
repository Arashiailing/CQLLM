/**
 * @name Misnamed function
 * @description Identifies functions that start with a capital letter and are the only such function in their file.
 *              This violates Python's naming convention which recommends function names to start with lowercase.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

// Query to detect functions with improper naming convention
from Function targetFunc
where
  // Ensure the function is defined in source code (not in libraries)
  targetFunc.inSource() and
  // Check if function name starts with a capital letter
  exists(string firstChar |
    firstChar = targetFunc.getName().prefix(1) and
    firstChar != firstChar.toLowerCase()
  ) and
  // Verify this is the only function with capital initial in its file
  not exists(Function anotherFunc |
    // Exclude the current function from comparison
    anotherFunc != targetFunc and
    // Ensure both functions are in the same file
    anotherFunc.getLocation().getFile() = targetFunc.getLocation().getFile() and
    // Check the other function also starts with a capital letter
    exists(string otherFirstChar |
      otherFirstChar = anotherFunc.getName().prefix(1) and
      otherFirstChar != otherFirstChar.toLowerCase()
    )
  )
select targetFunc, "Function names should start in lowercase."