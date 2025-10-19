/**
 * @name Number of calls
 * @description The total number of calls in a function.
 * @kind treemap
 * @id py/number-of-calls-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 */

import python  // 引入Python分析模块，用于处理Python源代码的度量分析

// 从FunctionMetrics类中检索函数度量数据
from FunctionMetrics callableUnit
// 计算每个函数的调用次数，并按降序排列
// 这样可以优先显示调用最频繁的函数
select callableUnit, callableUnit.getNumberOfCalls() as invocationCount order by invocationCount desc