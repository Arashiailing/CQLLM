/**
 * @name Misnamed function
 * @description Detects functions that start with uppercase letters, which contradicts Python naming conventions.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python  // Import Python library for analyzing Python source code

from Function functionObj
where
  // Verify the function is defined within source code
  functionObj.inSource() and
  
  // Define a helper condition to check if a function name starts with uppercase
  (exists(string firstChar |
    firstChar = functionObj.getName().prefix(1) and  // Extract the first character of the function name
    not firstChar = firstChar.toLowerCase()  // Confirm the character is uppercase
  )) and
  
  // Exclude functions that have duplicates with uppercase names in the same file
  not (exists(Function duplicateFunc |
    duplicateFunc != functionObj and  // Ensure it's a different function
    duplicateFunc.getLocation().getFile() = functionObj.getLocation().getFile() and  // Same file location
    // Check if the duplicate function also starts with uppercase
    exists(string duplicateFirstChar |
      duplicateFirstChar = duplicateFunc.getName().prefix(1) and
      not duplicateFirstChar = duplicateFirstChar.toLowerCase()
    )
  ))
select functionObj, "Function names should start in lowercase."  // Report the function with a recommendation