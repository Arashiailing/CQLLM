/**
 * @name Cyclomatic complexity of functions
 * @description This analysis calculates the cyclomatic complexity metric for Python functions.
 *              Cyclomatic complexity measures the number of linearly independent paths through
 *              a function's code, providing insight into its decision logic. Functions with
 *              higher complexity scores typically contain more branching points, potentially
 *              requiring more comprehensive testing efforts and possibly impacting code maintainability.
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

// For each Python function, determine its cyclomatic complexity score
from Function func, int complexityValue
// Retrieve the cyclomatic complexity metric for the function
where complexityValue = func.getMetrics().getCyclomaticComplexity()
// Output the function along with its complexity, sorted by highest complexity first
select func, complexityValue order by complexityValue desc