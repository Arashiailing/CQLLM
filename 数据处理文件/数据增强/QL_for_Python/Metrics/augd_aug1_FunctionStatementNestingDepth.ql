/**
 * @name Function Statement Nesting Depth Analysis
 * @description Measures the maximum nesting level of statements within each function.
 *              Elevated nesting levels typically correlate with higher complexity and lower code maintainability.
 * @kind treemap
 * @id py/statement-nesting-depth-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags maintainability
 *       complexity
 */

import python

// Extract functions along with their statement nesting depth measurements
from FunctionMetrics examinedFunction, int nestingLevel
where nestingLevel = examinedFunction.getStatementNestingDepth()
// Display the function and its nesting depth, arranged by depth from highest to lowest
select examinedFunction, nestingLevel order by nestingLevel desc