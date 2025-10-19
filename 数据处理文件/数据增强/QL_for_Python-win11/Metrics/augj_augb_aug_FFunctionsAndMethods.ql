/**
 * @name Functions and methods per file
 * @description Computes the number of functions and methods in each Python file.
 * @kind treemap
 * @id py/functions-and-methods-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // Import Python module for code structure analysis

// For each Python module, calculate the number of contained functions
from Module file, int methodCount
// Count all non-lambda functions that belong to the module
where methodCount = count(Function method | 
       method.getEnclosingModule() = file and 
       method.getName() != "lambda")
// Display the module and its function count, sorted by count in descending order
select file, methodCount order by methodCount desc