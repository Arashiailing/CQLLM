/**
 * @name Number of parameters without defaults
 * @description Counts the parameters in a function that lack default value assignments.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 导入Python模块，提供分析Python代码的基础功能

// 获取所有函数指标
from FunctionMetrics functionMetric
// 计算每个函数的无默认值参数数量
select functionMetric, 
       functionMetric.getNumberOfParametersWithoutDefault() as paramCount 
// 按参数数量降序排序
order by paramCount desc