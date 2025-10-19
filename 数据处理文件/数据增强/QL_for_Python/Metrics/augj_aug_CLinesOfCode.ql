/**
 * @name Function Code Size Analysis
 * @description Quantifies and visualizes the lines of code (LOC) per function
 *              to identify functions that may be too large, potentially violating
 *              the single responsibility principle and indicating refactoring opportunities.
 * @kind treemap
 * @id py/lines-of-code-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg sum max
 * @tags maintainability
 * @severity info
 */

import python // Import Python module for analyzing Python source code

// Calculate LOC for each function and prepare results
from Function func
select func, 
       func.getMetrics().getNumberOfLinesOfCode() as locCount 
order by locCount desc