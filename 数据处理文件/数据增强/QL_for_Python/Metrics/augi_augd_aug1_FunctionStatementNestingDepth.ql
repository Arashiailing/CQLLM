/**
 * @name Function Statement Nesting Depth Analysis
 * @description Quantifies the maximum nesting depth of statements within each function.
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

// Analyze functions and compute their maximum statement nesting depth
from FunctionMetrics targetFunction, int maxNestingDepth
where maxNestingDepth = targetFunction.getStatementNestingDepth()
// Output functions sorted by descending nesting depth for prioritization
select targetFunction, maxNestingDepth order by maxNestingDepth desc