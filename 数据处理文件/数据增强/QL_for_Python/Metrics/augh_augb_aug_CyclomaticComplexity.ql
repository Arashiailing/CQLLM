/**
 * @name Cyclomatic complexity of functions
 * @description Measures the cyclomatic complexity for each Python function. This metric
 *              indicates the number of linearly independent paths through a function's code.
 *              Higher complexity values suggest more branching logic, necessitating more
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

// This query processes all Python functions to determine their cyclomatic complexity metric
from Function targetFunction, int cyclomaticComplexityValue
// Calculate the complexity score by accessing the function's metrics and retrieving the cyclomatic complexity value
where cyclomaticComplexityValue = targetFunction.getMetrics().getCyclomaticComplexity()
// Output includes each function and its corresponding complexity metric, with results sorted by complexity in descending order
select targetFunction, cyclomaticComplexityValue order by cyclomaticComplexityValue desc