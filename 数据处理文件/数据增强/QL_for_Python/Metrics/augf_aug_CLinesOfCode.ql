/**
 * @name Function Code Size Analysis
 * @description Measures and reports the line count for each function in the codebase,
 *              assisting developers in identifying functions that may be too large
 *              and potentially violating the single responsibility principle.
 * @kind treemap
 * @id py/lines-of-code-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg sum max
 * @tags maintainability
 * @severity info
 */

import python // Import Python module for analyzing Python source code

// Retrieve all Python functions and compute their code size metrics
from Function func
select func, 
       func.getMetrics().getNumberOfLinesOfCode() as lineCount 
order by lineCount desc