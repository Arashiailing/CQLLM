/**
 * @name Statement nesting depth
 * @description Calculates and displays the maximum nesting depth of statements within each function.
 *              Higher values indicate more complex control flow structures.
 * @kind treemap
 * @id py/statement-nesting-depth-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags maintainability
 *       complexity
 */

import python

// Select all Python functions and compute their statement nesting depth
// Results are presented in descending order of nesting depth to highlight
// functions with the most complex control flow structures
from FunctionMetrics analyzedFunction
select analyzedFunction, analyzedFunction.getStatementNestingDepth() as nestingDepth 
order by nestingDepth desc