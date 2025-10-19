/**
 * @name Function Code Size Analysis
 * @description This analysis measures the size of each function in terms of lines of code.
 *              Large functions might indicate a violation of the single responsibility principle
 *              and could be candidates for refactoring.
 * @kind treemap
 * @id py/lines-of-code-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg sum max
 * @tags maintainability
 * @severity info
 */

import python // Import Python module for analyzing Python source code

// Select all Python functions
from Function func
// Calculate their code size
select func, func.getMetrics().getNumberOfLinesOfCode() as codeSize 
// Order by code size in descending order
order by codeSize desc