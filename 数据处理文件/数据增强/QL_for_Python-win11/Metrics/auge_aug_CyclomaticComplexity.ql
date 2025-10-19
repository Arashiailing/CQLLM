/**
 * @name Cyclomatic complexity of functions
 * @description Computes the cyclomatic complexity metric for each Python function.
 *              This metric quantifies the number of linearly independent execution paths
 *              through a function's code. Higher values indicate increased branching
 *              logic, which typically requires more extensive testing and may reduce
 *              code maintainability.
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

// Identify all functions and compute their cyclomatic complexity scores
from Function func, int complexityScore
// Associate each function with its calculated cyclomatic complexity value
where complexityScore = func.getMetrics().getCyclomaticComplexity()
// Display results with functions and their complexity metrics, sorted by complexity in descending order
select func, complexityScore order by complexityScore desc