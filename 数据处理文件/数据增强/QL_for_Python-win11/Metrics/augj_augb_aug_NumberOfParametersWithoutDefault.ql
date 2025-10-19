/**
 * @name Number of parameters without defaults
 * @description Counts parameters in Python functions that lack default values, indicating potential complexity.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 导入Python模块，支持Python代码的静态分析

// 分析所有Python函数，识别那些可能因必需参数过多而导致复杂度增加的函数
// 通过统计没有默认值的参数数量，我们可以评估函数的调用复杂度
from FunctionMetrics funcMetrics
// 计算每个函数中必须提供的参数数量（即没有默认值的参数）
// 这些参数是调用函数时必须显式传递的，增加了函数使用的复杂性
select funcMetrics, 
       funcMetrics.getNumberOfParametersWithoutDefault() as requiredParamCount
// 按必需参数数量降序排列，以便优先关注高复杂度函数
order by requiredParamCount desc