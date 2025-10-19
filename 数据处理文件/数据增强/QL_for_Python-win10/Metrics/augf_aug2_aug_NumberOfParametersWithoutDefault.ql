/**
 * @name Number of parameters without defaults
 * @description Counts how many parameters in each function do not have default values assigned.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 导入Python模块以便进行静态代码分析

// 查询所有Python函数并统计其无默认值参数的数量
from FunctionMetrics functionObj
select functionObj, 
       functionObj.getNumberOfParametersWithoutDefault() as noDefaultParamNum 
// 按无默认值参数数量从高到低排序结果
order by noDefaultParamNum desc