/**
 * @name Cyclomatic complexity of functions
 * @description This query calculates the cyclomatic complexity for each Python function.
 *              Cyclomatic complexity is a software metric that quantifies the number of
 *              linearly independent paths through a function's source code. Higher values
 *              indicate more complex control flow, which typically requires more thorough
 *              testing and may reduce code maintainability.
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

// Define the source of functions and their complexity scores
from Function func, int complexityScore
// Calculate the cyclomatic complexity for each function
where complexityScore = func.getMetrics().getCyclomaticComplexity()
// Output the results, ordered by complexity (highest first)
select func, complexityScore order by complexityScore desc