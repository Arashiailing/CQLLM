/**
 * @name Function code line count
 * @description Computes and presents the line count for each Python function,
 *              sorted in descending order by size. This metric aids in identifying
 *              functions that might be overly complex and candidates for refactoring.
 * @kind treemap
 * @id py/lines-of-code-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // Import Python module for analyzing Python source code

// Query all Python functions and calculate their respective code line counts,
// sorting by the highest counts first to emphasize potentially problematic functions
from Function func
select func, func.getMetrics().getNumberOfLinesOfCode() as codeLines order by codeLines desc