/**
 * @name Number of calls
 * @description Calculates and displays the total number of calls within each Python function.
 * @kind treemap
 * @id py/number-of-calls-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 */

import python  // 导入Python分析模块，提供对Python源代码的度量分析能力

// 从FunctionMetrics类中获取包含度量信息的函数
from FunctionMetrics analyzedFunction
// 定义调用次数变量，存储每个函数中的总调用数
// 结果按调用次数降序排列，优先展示高频调用函数
select analyzedFunction, analyzedFunction.getNumberOfCalls() as callCount order by callCount desc