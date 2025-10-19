/**
 * @name Number of calls
 * @description The total number of calls in a function.
 * @kind treemap
 * @id py/number-of-calls-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 */

import python  // 导入python库，用于分析Python代码

// 从FunctionMetrics类中选择函数和调用次数，并按调用次数降序排列
from FunctionMetrics func
select func, func.getNumberOfCalls() as n order by n desc
