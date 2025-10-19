/**
 * @name Statement nesting depth
 * @description Calculates and visualizes the maximum depth of nested statements within each function.
 *              Higher nesting depth often indicates increased complexity and reduced maintainability.
 * @kind treemap
 * @id py/statement-nesting-depth-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags maintainability
 *       complexity
 */

import python

// Extract functions and compute their statement nesting complexity measurements
from FunctionMetrics measuredFunction
// Present each function with its calculated nesting depth, sorted from highest to lowest
select measuredFunction, measuredFunction.getStatementNestingDepth() as depth order by depth desc