/**
 * @name Number of parameters without defaults
 * @description Identifies and counts function parameters that lack default values.
 *              Functions with many parameters without defaults may be harder to test and maintain.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 导入Python模块，支持Python代码的静态分析

// 分析所有Python函数，获取其度量指标
from FunctionMetrics callableMetrics
// 计算每个函数中未设置默认值的参数数量
// 这有助于评估函数的复杂性和可测试性
select callableMetrics, 
       callableMetrics.getNumberOfParametersWithoutDefault() as paramCount 
// 结果按无默认值参数数量降序排列，便于识别复杂度最高的函数
order by paramCount desc