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

import python  // Python分析模块导入，支持对Python源代码进行静态分析

// 查询所有Python函数，统计其无默认值的参数数量
from FunctionMetrics analyzedFunction
// 提取各函数中必须显式传入的参数（即未设置默认值的参数）
select analyzedFunction, 
       analyzedFunction.getNumberOfParametersWithoutDefault() as mandatoryParamCount 
// 根据必需参数数量降序排列，突出显示可能复杂度过高的函数
order by mandatoryParamCount desc