/**
 * @name Number of parameters without defaults
 * @description Calculates the count of function parameters that lack default value assignments.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 导入Python模块以进行代码静态分析

// 查询函数指标数据源，获取每个可调用实体的无默认值参数统计信息
from FunctionMetrics funcMetric

// 提取函数指标实体及其无默认值参数的数量
select funcMetric, 
       funcMetric.getNumberOfParametersWithoutDefault() as nonDefaultParamCount 

// 按无默认值参数数量从高到低排序结果
order by nonDefaultParamCount desc