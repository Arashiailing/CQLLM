/**
 * @name Cyclomatic complexity of functions
 * @description Computes cyclomatic complexity metrics for Python functions. This metric quantifies
 *              decision paths in source code by counting linearly independent execution routes.
 *              Elevated complexity scores suggest increased branching logic, necessitating more
 *              comprehensive testing and potentially impacting code maintainability.
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

// Identify functions and their associated cyclomatic complexity measurements
from Function func, int complexityScore
// Directly compute complexity score during variable declaration
where complexityScore = func.getMetrics().getCyclomaticComplexity()
// Output results with functions and their complexity scores, ordered by descending complexity
select func, complexityScore order by complexityScore desc