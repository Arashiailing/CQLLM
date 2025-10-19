/**
 * @name Statement nesting depth
 * @description Computes the maximum nesting depth of statements within each function.
 *              Higher nesting depth indicates greater complexity and reduced maintainability.
 * @kind treemap
 * @id py/statement-nesting-depth-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags maintainability
 *       complexity
 */

import python

// Calculate nesting depth for each function and retrieve results
from FunctionMetrics funcMetrics
// Output function entities with their nesting depth metrics, ordered by depth (highest first)
select funcMetrics, funcMetrics.getStatementNestingDepth() as depth order by depth desc