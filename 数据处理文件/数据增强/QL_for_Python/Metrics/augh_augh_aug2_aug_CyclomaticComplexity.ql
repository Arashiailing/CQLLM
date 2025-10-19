/**
 * @name Function cyclomatic complexity analysis
 * @description Measures the cyclomatic complexity of Python functions by calculating the number of
 *              independent paths through source code. Higher values indicate more branching logic,
 *              requiring increased testing effort and potentially reducing maintainability.
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

// Identify all Python functions and compute their cyclomatic complexity metrics
from Function analyzedFunction, int complexityScore
// Calculate complexity score for each function using its metrics
where complexityScore = analyzedFunction.getMetrics().getCyclomaticComplexity()
// Output results showing functions with corresponding complexity scores, sorted by highest complexity first
select analyzedFunction, complexityScore order by complexityScore desc