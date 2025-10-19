/**
 * @name Function Code Size Analysis
 * @description Identifies and measures the size of Python functions by counting lines of code.
 *              Functions with excessive line counts may violate the single responsibility principle
 *              and represent opportunities for code refactoring to improve maintainability.
 * @kind treemap
 * @id py/lines-of-code-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg sum max
 * @tags maintainability
 * @severity info
 */

import python // Import Python module for analyzing Python source code

// Define the target of our analysis: all Python functions
from Function targetFunction
// Calculate the lines of code (LOC) for each function
select targetFunction, targetFunction.getMetrics().getNumberOfLinesOfCode() as locCount
// Sort results in descending order to highlight largest functions first
order by locCount desc