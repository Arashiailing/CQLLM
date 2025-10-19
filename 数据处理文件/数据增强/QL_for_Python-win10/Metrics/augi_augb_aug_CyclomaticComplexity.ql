/**
 * @name Cyclomatic complexity of functions
 * @description Calculates the cyclomatic complexity metric for every Python function. This metric
 *              measures the count of linearly independent paths through a function's code. Functions
 *              with elevated complexity scores typically contain more branching logic, necessitating
 *              more comprehensive testing and potentially compromising code maintainability.
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

// This query processes all Python functions and determines their cyclomatic complexity
from Function pythonFunction, int cyclomaticValue
// The cyclomatic complexity value is retrieved via the getMetrics().getCyclomaticComplexity() method
where cyclomaticValue = pythonFunction.getMetrics().getCyclomaticComplexity()
// Output displays each function alongside its complexity score, arranged in descending order
select pythonFunction, cyclomaticValue order by cyclomaticValue desc