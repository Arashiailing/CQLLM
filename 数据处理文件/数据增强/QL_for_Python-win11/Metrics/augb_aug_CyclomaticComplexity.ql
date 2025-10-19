/**
 * @name Cyclomatic complexity of functions
 * @description Computes the cyclomatic complexity metric for each Python function. This metric
 *              quantifies the number of independent paths through a function's code. Functions
 *              with higher complexity scores tend to have more branching logic, requiring more
 *              thorough testing and potentially reducing code maintainability.
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

// This query identifies all Python functions and calculates their cyclomatic complexity
from Function func, int complexityScore
// The cyclomatic complexity is obtained using the getMetrics().getCyclomaticComplexity() method
where complexityScore = func.getMetrics().getCyclomaticComplexity()
// Results are presented with each function and its complexity score, sorted in descending order
select func, complexityScore order by complexityScore desc