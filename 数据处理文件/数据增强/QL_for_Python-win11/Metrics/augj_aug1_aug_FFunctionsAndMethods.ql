/**
 * @name File-level function and method count
 * @description Provides a count of all functions and methods contained within each Python file/module, excluding lambda functions.
 * @kind treemap
 * @id py/functions-and-methods-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python

// Define variables for analysis: target module and its function count
from Module targetModule, int funcCount
// Calculate the total number of non-lambda functions in each module
where 
  // Count all functions that are not lambda expressions
  funcCount = count(Function function | 
    function.getEnclosingModule() = targetModule and 
    not function.getName() = "lambda"
  )
// Output the modules with their respective function counts, sorted in descending order
select targetModule, funcCount order by funcCount desc