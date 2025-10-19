/**
 * @name Statement nesting depth
 * @description The maximum nesting depth of statements in a function.
 * @kind treemap
 * @id py/statement-nesting-depth-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags maintainability
 *       complexity
 */

import python

// 从FunctionMetrics类中选择函数和其语句嵌套深度，并按深度降序排列
from FunctionMetrics func
select func, func.getStatementNestingDepth() as n order by n desc
