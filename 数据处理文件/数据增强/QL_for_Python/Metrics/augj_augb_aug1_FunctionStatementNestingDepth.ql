/**
 * @name Function Statement Nesting Depth Analysis
 * @description This query calculates and presents the maximum nesting depth of statements within each function.
 *              Deeply nested code often indicates increased complexity and reduced maintainability.
 * @kind treemap
 * @id py/statement-nesting-depth-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags maintainability
 *       complexity
 */

import python

// Source: Functions to be analyzed for nesting depth
from FunctionMetrics analyzedFunction
// Output: Function and its maximum nesting depth, sorted by depth (highest first)
select analyzedFunction, 
       analyzedFunction.getStatementNestingDepth() as nestingLevel 
order by nestingLevel desc