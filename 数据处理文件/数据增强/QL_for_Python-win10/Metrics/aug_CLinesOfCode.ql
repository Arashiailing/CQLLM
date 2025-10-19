/**
 * @name Function Code Size Analysis
 * @description Calculates and displays the number of lines of code for each function,
 *              helping identify potentially oversized functions that may violate
 *              single responsibility principle.
 * @kind treemap
 * @id py/lines-of-code-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg sum max
 * @tags maintainability
 * @severity info
 */

import python // Import Python module for analyzing Python source code

// Select all Python functions and calculate their code size
from Function targetFunction
select targetFunction, 
       targetFunction.getMetrics().getNumberOfLinesOfCode() as codeSize 
order by codeSize desc