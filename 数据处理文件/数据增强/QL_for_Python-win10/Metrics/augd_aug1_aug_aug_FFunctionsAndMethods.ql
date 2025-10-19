/**
 * @name Functions and methods per file
 * @description Provides a count of all functions and methods contained in each Python file.
 * @kind treemap
 * @id py/functions-and-methods-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // Import Python module for code structure analysis

// This query analyzes each Python module to determine how many functions it contains
// Note: Lambda functions are excluded from the count as they are anonymous
from Module pythonModule, int functionCount
where 
    // Count all named functions that belong to the current module
    functionCount = count(Function function | 
        // Verify the function is defined within the module being analyzed
        function.getEnclosingModule() = pythonModule and 
        // Filter out lambda functions which don't have explicit names
        function.getName() != "lambda")
// Return the module and its function count, sorted from highest to lowest
select pythonModule, functionCount order by functionCount desc