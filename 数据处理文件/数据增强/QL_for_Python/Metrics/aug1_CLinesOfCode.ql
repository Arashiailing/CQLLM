/**
 * @name Lines of code in functions
 * @description Calculates and displays the number of lines of code in each Python function,
 *              ordered by size in descending order. This metric helps identify potentially
 *              complex functions that may need refactoring.
 * @kind treemap
 * @id py/lines-of-code-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // Import Python module for analyzing Python source code

// Select all Python functions and their corresponding lines of code,
// ordered by the line count in descending order to highlight larger functions first
from Function targetFunction
select targetFunction, targetFunction.getMetrics().getNumberOfLinesOfCode() as lineCount order by lineCount desc