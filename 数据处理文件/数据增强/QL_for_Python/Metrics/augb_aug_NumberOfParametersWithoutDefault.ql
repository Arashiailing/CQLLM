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

// 分析所有Python函数，统计无默认值的参数数量
from FunctionMetrics pythonFunction
// 获取每个函数中必须提供的参数数量（即无默认值的参数）
select pythonFunction, 
       pythonFunction.getNumberOfParametersWithoutDefault() as requiredParamCount 
// 按必需参数数量降序排列，突出高复杂度函数
order by requiredParamCount desc