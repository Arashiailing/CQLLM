/**
 * @name Function code line count
 * @description Measures the number of lines of code for each Python function,
 *              displaying results in descending order. This helps identify
 *              potentially complex functions that may require refactoring.
 * @kind treemap
 * @id py/lines-of-code-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // Import Python module for analyzing Python source code

// Calculate the line count for each Python function and present results
// sorted from largest to smallest to highlight functions with excessive complexity
from Function targetFunction
where targetFunction.getName() != "" // Ensure we only consider named functions
select targetFunction, 
       targetFunction.getMetrics().getNumberOfLinesOfCode() as lineCount 
order by lineCount desc