/**
 * @name Statement nesting depth
 * @description Computes and displays the maximum nesting level of statements within functions.
 *              Deeper nesting often correlates with higher complexity and lower code maintainability.
 * @kind treemap
 * @id py/statement-nesting-depth-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags maintainability
 *       complexity
 */

import python

// Extract functions along with their statement nesting depth measurements
from FunctionMetrics measuredFunction
// Present the function and its nesting depth, arranged by depth from highest to lowest
select measuredFunction, measuredFunction.getStatementNestingDepth() as depth order by depth desc