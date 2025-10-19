/**
 * @name Number of calls
 * @description The total number of calls in a function.
 * @kind treemap
 * @id py/number-of-calls-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 */

import python  // 导入Python分析库，用于代码度量计算

// 查询函数指标数据，获取每个函数的调用次数统计
from FunctionMetrics funcMetric, int invocationCount
where invocationCount = funcMetric.getNumberOfCalls()
// 输出函数对象及其调用次数，按调用次数从高到低排序
select funcMetric, invocationCount order by invocationCount desc