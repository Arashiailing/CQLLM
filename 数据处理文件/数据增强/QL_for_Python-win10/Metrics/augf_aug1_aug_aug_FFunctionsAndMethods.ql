/**
 * @name Functions and methods per file
 * @description Provides a statistical overview of function and method distribution across Python source files.
 * @kind treemap
 * @id py/functions-and-methods-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // Import Python module for code structure analysis

// This query performs an analysis of Python modules to quantify the number of defined functions
// The analysis intentionally excludes anonymous lambda functions from the count
from Module pythonModule, int functionCount
where 
    // Calculate the total count of named functions within each Python module
    functionCount = count(Function functionItem | 
        // Ensure the function is properly scoped within the module being analyzed
        functionItem.getEnclosingModule() = pythonModule and 
        // Exclude lambda functions since they are anonymous constructs
        functionItem.getName() != "lambda")
// Output results showing each module and its corresponding function count, 
// sorted in descending order to highlight modules with highest function density
select pythonModule, functionCount order by functionCount desc