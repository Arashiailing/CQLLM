/**
 * @name Number of calls
 * @description The total number of calls within each function.
 * @kind treemap
 * @id py/number-of-calls-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 */

import python  // 导入Python分析库，用于代码度量计算

// 从函数指标中提取数据并计算调用次数
from FunctionMetrics functionMetric
// 选择函数实体及其对应的调用次数，按调用频率降序排列
select functionMetric, functionMetric.getNumberOfCalls() as callCount order by callCount desc