/**
 * @name Function Statement Nesting Depth Analysis
 * @description Quantifies the maximum nesting depth of statements within functions.
 *              Higher nesting levels indicate increased complexity and reduced maintainability.
 * @kind treemap
 * @id py/statement-nesting-depth-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags maintainability
 *       complexity
 */

import python

// Identify functions for nesting depth evaluation
from FunctionMetrics func
// Calculate and display maximum nesting depth per function, sorted by complexity
select func, func.getStatementNestingDepth() as depth
order by depth desc