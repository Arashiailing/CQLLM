/**
 * @name Statement nesting depth
 * @description Measures and displays the deepest level of statement nesting found in each function.
 *              Excessive nesting typically suggests higher complexity and poorer code maintainability.
 * @kind treemap
 * @id py/statement-nesting-depth-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags maintainability
 *       complexity
 */

import python

// Identify functions for nesting depth analysis
from FunctionMetrics measuredFunction
// Calculate and present the maximum nesting depth for each function, ordered from highest to lowest
select measuredFunction, measuredFunction.getStatementNestingDepth() as nestingLevel order by nestingLevel desc