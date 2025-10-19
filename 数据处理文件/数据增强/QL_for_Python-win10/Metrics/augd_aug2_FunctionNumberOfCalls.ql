/**
 * @name Number of calls
 * @description The total number of calls in a function.
 * @kind treemap
 * @id py/number-of-calls-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 */

import python  // 导入Python分析模块，提供Python源代码的度量分析功能

// 获取函数度量数据并计算调用次数
from FunctionMetrics measuredFunction
// 定义调用次数变量，存储每个函数的总调用数
// 按调用次数降序排列，使高频调用函数优先显示
select measuredFunction, measuredFunction.getNumberOfCalls() as callCount order by callCount desc