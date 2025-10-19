/**
 * @name Functions and methods per file
 * @description Provides a statistical overview of function and method density across Python source files.
 * @kind treemap
 * @id py/functions-and-methods-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // Import Python module for code structure analysis

// This query examines Python modules to quantify the number of defined functions and methods
// Note: Anonymous lambda functions are excluded from this calculation
from Module pyModule, int functionCount
where 
    // Calculate the total count of functions within each module
    functionCount = count(Function method | 
        // Ensure the function is defined in the current module being processed
        method.getEnclosingModule() = pyModule and 
        // Exclude lambda functions from the count as they are anonymous constructs
        method.getName() != "lambda")
// Output the module and its corresponding function count, sorted in descending order
select pyModule, functionCount order by functionCount desc