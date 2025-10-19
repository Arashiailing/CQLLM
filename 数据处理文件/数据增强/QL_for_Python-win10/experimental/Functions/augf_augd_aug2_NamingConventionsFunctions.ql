/**
 * @name Misnamed function
 * @description Detects functions that violate Python naming conventions by starting with uppercase letters.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * 
 * This analysis identifies functions whose names begin with uppercase letters, which goes against PEP8 standards.
 * To prevent duplicate reporting within the same file, the query excludes functions when another uppercase-named
 * function exists in the same file. This approach may reduce the number of reports in files containing
 * multiple such functions.
 */

import python

from Function functionDef
where
  // Ensure function is source-defined (not library/built-in)
  functionDef.inSource() and
  // Check if function name starts with uppercase letter
  functionDef.getName().prefix(1) != functionDef.getName().prefix(1).toLowerCase() and
  // Exclude functions if another uppercase-named function exists in same file
  not exists(Function similarFunction |
    similarFunction != functionDef and
    similarFunction.getLocation().getFile() = functionDef.getLocation().getFile() and
    similarFunction.getName().prefix(1) != similarFunction.getName().prefix(1).toLowerCase()
  )
select functionDef, "Function names should start in lowercase."