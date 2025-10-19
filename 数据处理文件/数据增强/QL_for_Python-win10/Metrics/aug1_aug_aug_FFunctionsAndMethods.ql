/**
 * @name Functions and methods per file
 * @description Calculates the count of functions and methods within each Python file.
 * @kind treemap
 * @id py/functions-and-methods-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // Import Python module for code structure analysis

// This query analyzes each Python module to determine the total number of functions it contains
// Lambda functions are specifically excluded from this count
from Module sourceFile, int totalFunctions
where 
    // Count all non-lambda functions that belong to the current module
    totalFunctions = count(Function func | 
        // Verify the function is defined within the source file being analyzed
        func.getEnclosingModule() = sourceFile and 
        // Filter out lambda functions as they are anonymous and not named
        func.getName() != "lambda")
// Return the source file and its function count, ordered from highest to lowest count
select sourceFile, totalFunctions order by totalFunctions desc