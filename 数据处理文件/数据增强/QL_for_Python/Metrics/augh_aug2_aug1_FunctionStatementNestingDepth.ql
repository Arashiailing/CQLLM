/**
 * @name Statement nesting depth
 * @description Computes and visualizes the maximum nesting depth of statements within each function.
 *              Increased nesting depth typically correlates with higher complexity and reduced maintainability.
 * @kind treemap
 * @id py/statement-nesting-depth-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags maintainability
 *       complexity
 */

import python

// Identify functions with associated metrics and retrieve their nesting complexity
from FunctionMetrics funcWithMetrics
// Output each function alongside its calculated nesting depth, sorted in descending order
select funcWithMetrics, funcWithMetrics.getStatementNestingDepth() as depth order by depth desc