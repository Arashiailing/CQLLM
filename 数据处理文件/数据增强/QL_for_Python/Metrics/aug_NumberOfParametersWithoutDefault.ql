/**
 * @name Number of parameters without defaults
 * @description The number of parameters in a function that are not defined with default values.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 导入Python模块，支持Python代码的静态分析

// 查询所有Python函数
from FunctionMetrics functionObj
// 计算每个函数中无默认值的参数数量
select functionObj, 
       functionObj.getNumberOfParametersWithoutDefault() as paramCount 
// 按无默认值参数数量降序排列结果
order by paramCount desc