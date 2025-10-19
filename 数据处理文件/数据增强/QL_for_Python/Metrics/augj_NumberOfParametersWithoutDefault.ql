/**
 * @name Number of parameters without defaults
 * @description The number of parameters of a function that do not have default values defined.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 导入Python模块，提供分析Python代码的基础功能

// 查询每个函数的参数数量（不包括有默认值的参数）
from FunctionMetrics functionObj
select 
    functionObj, 
    functionObj.getNumberOfParametersWithoutDefault() as paramCount 
order by paramCount desc
// 按照无默认值参数数量降序排列结果，便于识别参数最多的函数