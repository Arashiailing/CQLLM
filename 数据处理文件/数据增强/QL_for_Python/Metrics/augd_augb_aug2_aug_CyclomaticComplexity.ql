/**
 * @name Cyclomatic complexity of functions
 * @description Evaluates the cyclomatic complexity metric for Python functions. This metric
 *              quantifies the number of linearly independent paths through a function's code,
 *              reflecting its decision logic density. Functions with elevated complexity scores
 *              typically contain more branching constructs, necessitating comprehensive testing
 *              and potentially impacting code maintainability.
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

// Identify all Python functions and determine their respective cyclomatic complexity values
from Function func, int cyclomaticValue
// Retrieve the cyclomatic complexity metric for each identified function
where cyclomaticValue = func.getMetrics().getCyclomaticComplexity()
// Present the function entities along with their complexity scores, ordered from highest to lowest complexity
select func, cyclomaticValue order by cyclomaticValue desc