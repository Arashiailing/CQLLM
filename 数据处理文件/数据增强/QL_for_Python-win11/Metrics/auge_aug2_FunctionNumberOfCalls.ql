/**
 * @name Number of calls
 * @description The total number of calls in a function.
 * @kind treemap
 * @id py/number-of-calls-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 */

import python  // 导入Python分析模块，用于处理Python源代码的度量分析

// 从FunctionMetrics类中获取函数度量数据
// 计算每个函数的调用次数，并按照调用次数降序排列
// 这样可以优先展示调用最频繁的函数
from FunctionMetrics funcMetric
select funcMetric, funcMetric.getNumberOfCalls() as callCount 
order by callCount desc