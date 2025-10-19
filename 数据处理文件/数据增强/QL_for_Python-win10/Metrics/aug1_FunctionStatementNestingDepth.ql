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

// Retrieve functions and their corresponding statement nesting depth metrics
from FunctionMetrics analyzedFunction
// Output the function and its nesting depth, sorted by depth in descending order
select analyzedFunction, analyzedFunction.getStatementNestingDepth() as depth order by depth desc