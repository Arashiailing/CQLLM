/**
 * @name Functions and methods per file
 * @description Provides a quantitative analysis of functions and methods distribution across Python files.
 * @kind treemap
 * @id py/functions-and-methods-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // Import Python module for code structure analysis

// Define the main query to analyze Python modules and their function counts
from Module pythonModule, int functionCount
// Calculate the total number of non-lambda functions within each Python module
where functionCount = count(Function function | 
       // Ensure the function is contained within the current module
       function.getEnclosingModule() = pythonModule and 
       // Exclude lambda functions from the count
       function.getName() != "lambda")
// Output results showing each Python module with its corresponding function count,
// sorted in descending order to highlight files with the most functions
select pythonModule, functionCount order by functionCount desc