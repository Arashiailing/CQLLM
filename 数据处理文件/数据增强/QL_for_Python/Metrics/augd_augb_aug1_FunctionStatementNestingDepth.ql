/**
 * @name Function Statement Nesting Depth Analysis
 * @description This analysis quantifies the maximum nesting depth within each function's statements.
 *              Higher nesting levels often indicate increased complexity and reduced code readability.
 * @kind treemap
 * @id py/statement-nesting-depth-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags maintainability
 *       complexity
 */

import python

// Define the source of functions for nesting depth analysis
from FunctionMetrics analyzedFunction

// Calculate the maximum nesting depth for each analyzed function
// and present results sorted by depth in descending order
select analyzedFunction, 
       analyzedFunction.getStatementNestingDepth() as maxNestingDepth 
order by maxNestingDepth desc