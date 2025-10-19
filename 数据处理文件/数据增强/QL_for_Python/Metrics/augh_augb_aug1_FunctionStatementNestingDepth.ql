/**
 * @name Statement nesting depth
 * @description Calculates and presents the maximum nesting depth of statements within each function.
 *              Deep nesting often indicates increased complexity and reduced code readability.
 * @kind treemap
 * @id py/statement-nesting-depth-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags maintainability
 *       complexity
 */

import python

// Identify functions for complexity analysis based on statement nesting
from FunctionMetrics funcWithMetrics
// Compute and display the maximum nesting depth, prioritizing functions with higher complexity
select funcWithMetrics, funcWithMetrics.getStatementNestingDepth() as maxNestingDepth order by maxNestingDepth desc