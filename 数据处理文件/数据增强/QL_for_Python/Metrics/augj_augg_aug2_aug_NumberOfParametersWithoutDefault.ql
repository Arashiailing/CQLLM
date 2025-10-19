/**
 * @name Number of parameters without defaults
 * @description Counts function parameters that are not assigned default values.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 引入Python语言模块以支持代码分析

// 提取函数指标并计算无默认值参数数量
from FunctionMetrics funcMetrics
select funcMetrics, 
       funcMetrics.getNumberOfParametersWithoutDefault() as nonDefaultParamCount 
order by nonDefaultParamCount desc  // 按无默认值参数数量降序排列