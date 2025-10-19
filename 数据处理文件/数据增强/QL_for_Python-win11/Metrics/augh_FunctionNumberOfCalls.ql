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

// 从FunctionMetrics类中获取函数对象及其调用次数
from FunctionMetrics functionObj, int callCount
where callCount = functionObj.getNumberOfCalls()
// 选择函数对象和对应的调用次数，并按调用次数降序排列
select functionObj, callCount order by callCount desc