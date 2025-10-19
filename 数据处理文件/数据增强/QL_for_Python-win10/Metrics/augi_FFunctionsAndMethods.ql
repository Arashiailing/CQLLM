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

import python // Import Python module for analyzing Python source code

// Select each Python module and its corresponding function count
from Module moduleObj, int functionCount
// Where functionCount represents the number of functions in the module:
where functionCount = count(Function func | 
       func.getEnclosingModule() = moduleObj and 
       func.getName() != "lambda"
)
// Select the module and its function count, ordered by count in descending order
select moduleObj, functionCount order by functionCount desc