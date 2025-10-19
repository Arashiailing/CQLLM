/**
 * @name Functions and methods per file
 * @description Analyzes Python source files to determine the number of functions and methods contained within each file.
 * @kind treemap
 * @id py/functions-and-methods-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // Import Python module for code structure analysis

// For each Python source file, calculate the total number of defined functions and methods
from Module sourceFile, int functionTotal
// Compute the count of all regular functions (excluding lambda functions) in each module
where functionTotal = count(Function method | 
       method.getEnclosingModule() = sourceFile and 
       // Exclude anonymous lambda functions from the count
       not method.getName() = "lambda")
// Display the source file along with its function count, sorted from highest to lowest count
select sourceFile, functionTotal order by functionTotal desc