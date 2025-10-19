/**
 * @name Functions and methods per file
 * @description Provides a count of functions and methods contained in each Python source file.
 * @kind treemap
 * @id py/functions-and-methods-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // Import Python module for code structure analysis

// For each Python module, determine the number of functions and methods it contains
from Module fileContainer, int functionCount
// Count all non-lambda functions that belong to the module
where functionCount = count(Function functionItem | 
       functionItem.getEnclosingModule() = fileContainer and 
       functionItem.getName() != "lambda")
// Return the module and its function count, sorted from highest to lowest count
select fileContainer, functionCount order by functionCount desc