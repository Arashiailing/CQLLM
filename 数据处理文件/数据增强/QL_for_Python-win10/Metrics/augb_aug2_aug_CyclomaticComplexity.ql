/**
 * @name Cyclomatic complexity of functions
 * @description Measures the cyclomatic complexity for Python functions. This metric assesses
 *              the number of independent paths through a function's source code, indicating
 *              its decision-making logic. Higher complexity values suggest more branching
 *              structures, which may require extensive testing and could affect maintainability.
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

// For each Python function, compute its cyclomatic complexity score
from Function targetFunction, int complexityMetric
// Calculate the cyclomatic complexity for the function
where complexityMetric = targetFunction.getMetrics().getCyclomaticComplexity()
// Output the function and its complexity, sorted by descending complexity
select targetFunction, complexityMetric order by complexityMetric desc