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

// Analyze each source file to determine its function count
from Module sourceFile, int funcQuantity
// Calculation condition: tally all non-lambda functions within the module
where funcQuantity = count(Function func | 
       func.getEnclosingModule() = sourceFile and 
       func.getName() != "lambda")
// Output the module and its function count, sorted in descending order by function count
select sourceFile, funcQuantity order by funcQuantity desc