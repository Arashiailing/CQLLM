/**
 * @name Number of parameters without defaults
 * @description Identifies Python functions by counting parameters that lack default values, which can signal increased complexity.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 导入Python分析模块，提供对Python源代码的静态分析能力

// 此查询用于识别Python函数中需要显式传入的参数数量
// 较多的无默认值参数通常意味着函数复杂度较高，可能影响可测试性
from FunctionMetrics targetFunction
// 计算每个函数中未设置默认值的参数数量（即调用时必须提供的参数）
select targetFunction, 
       targetFunction.getNumberOfParametersWithoutDefault() as requiredParamCount 
// 按必需参数数量降序排列，以便优先识别可能复杂度过高的函数
order by requiredParamCount desc