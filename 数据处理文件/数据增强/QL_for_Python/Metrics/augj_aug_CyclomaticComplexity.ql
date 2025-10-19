/**
 * @name Cyclomatic complexity of functions
 * @description Calculates the cyclomatic complexity for each Python function. Cyclomatic complexity
 *              is a software metric that measures the number of linearly independent paths through
 *              a program's source code. Higher complexity values indicate more branching logic,
 *              which typically requires more test cases and may reduce maintainability.
 * @kind treemap
 * @id py/cyclomatic-complexity-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max sum
 * @tags testability
 *       complexity
 *       maintainability
 */

import python

// For each Python function, retrieve its cyclomatic complexity score
from Function func, int ccMetric
where ccMetric = func.getMetrics().getCyclomaticComplexity()
// Display functions sorted by their cyclomatic complexity in descending order
select func, ccMetric order by ccMetric desc