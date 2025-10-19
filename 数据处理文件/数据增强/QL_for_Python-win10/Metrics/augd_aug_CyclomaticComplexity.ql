/**
 * @name Cyclomatic Complexity Analysis for Python Functions
 * @description Computes the cyclomatic complexity metric for all Python functions in the codebase.
 *              Cyclomatic complexity quantifies the number of independent execution paths through
 *              a function's code. Functions with higher complexity scores contain more decision points
 *              (conditionals, loops), making them harder to understand, test, and maintain.
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

// For each Python function, calculate its cyclomatic complexity
from Function pythonFunction, int complexityScore
where complexityScore = pythonFunction.getMetrics().getCyclomaticComplexity()
// Output functions ordered by their complexity score in descending order
select pythonFunction, complexityScore order by complexityScore desc