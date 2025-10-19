/**
 * @name Function cyclomatic complexity analysis
 * @description Measures the cyclomatic complexity of Python functions, which calculates the number of
 *              independent paths through a function's source code. Higher values indicate more
 *              branching logic, requiring more thorough testing and potentially reducing code
 *              maintainability.
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

// Extract all Python functions and determine their cyclomatic complexity values
from Function targetFunction, int cyclomaticValue
// Calculate the cyclomatic complexity metric for each identified function
where cyclomaticValue = targetFunction.getMetrics().getCyclomaticComplexity()
// Present the results showing each function with its corresponding complexity score, sorted from highest to lowest
select targetFunction, cyclomaticValue order by cyclomaticValue desc