/**
 * @name Function Nesting Complexity Assessment
 * @description Measures the deepest level of statement nesting within functions. 
 *              Deep nesting often correlates with higher complexity and decreased maintainability.
 * @kind treemap
 * @id py/statement-nesting-depth-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags maintainability
 *       complexity
 */

import python

// Define the target functions for complexity assessment
from FunctionMetrics targetFunction

// Determine the maximum nesting depth for each function
// and present results sorted by depth in descending order
select targetFunction, 
       targetFunction.getStatementNestingDepth() as nestingLevel 
order by nestingLevel desc