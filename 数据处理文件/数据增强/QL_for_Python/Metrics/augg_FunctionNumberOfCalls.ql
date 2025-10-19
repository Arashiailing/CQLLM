/**
 * @name Number of calls
 * @description Calculates the total number of function calls within each function.
 *              This metric helps identify functions with high call complexity.
 * @kind treemap
 * @id py/number-of-calls-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 */

import python  // 导入python库，用于分析Python代码

// 从FunctionMetrics类中检索函数指标，计算每个函数的调用次数
// 按调用次数降序排列以突出高调用频率的函数
from FunctionMetrics functionMetric
select 
  functionMetric,  // 函数对象
  functionMetric.getNumberOfCalls() as callCount  // 函数调用次数
order by 
  callCount desc  // 按调用次数降序排列