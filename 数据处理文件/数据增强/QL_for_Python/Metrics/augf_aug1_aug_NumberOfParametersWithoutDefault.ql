/**
 * @name Non-default parameters count analysis
 * @description Computes the quantity of function parameters that are not assigned default values.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 引入Python模块以支持Python代码的静态分析能力

// 确定分析目标：所有函数定义
from FunctionMetrics callable
// 提取函数及其无默认值参数的统计信息
select callable, 
       callable.getNumberOfParametersWithoutDefault() as paramsWithoutDefault
// 根据无默认值参数数量从高到低排列结果
order by paramsWithoutDefault desc