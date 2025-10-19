/**
 * @name Statement nesting depth
 * @description This analysis calculates the maximum nesting depth of statements within each function.
 *              Higher nesting levels often indicate increased complexity and can reduce code readability.
 * @kind treemap
 * @id py/statement-nesting-depth-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags maintainability
 *       complexity
 */

import python

// Select functions to analyze their statement nesting depth
from FunctionMetrics analyzedFunction
// Compute the highest nesting depth per function and present results in descending order
select analyzedFunction, analyzedFunction.getStatementNestingDepth() as depthValue order by depthValue desc