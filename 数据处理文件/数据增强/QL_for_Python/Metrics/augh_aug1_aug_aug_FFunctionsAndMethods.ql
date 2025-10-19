/**
 * @name Functions and methods per file
 * @description Analyzes Python files to count the number of named functions and methods, 
 *              excluding anonymous lambda functions. Results are presented in descending order
 *              based on function count per file.
 * @kind treemap
 * @id py/functions-and-methods-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // Import Python module for code structure analysis

// This query examines each Python module to quantify the number of named functions
// Lambda functions are excluded from the count as they are anonymous constructs
from Module pythonModule, int functionCount
where 
    // Calculate the total count of named functions within the current module
    functionCount = count(Function function | 
        // Ensure the function is defined within the module being analyzed
        function.getEnclosingModule() = pythonModule and 
        // Exclude lambda functions since they are anonymous and not explicitly named
        function.getName() != "lambda")
// Output the module and its corresponding function count, sorted in descending order
select pythonModule, functionCount order by functionCount desc