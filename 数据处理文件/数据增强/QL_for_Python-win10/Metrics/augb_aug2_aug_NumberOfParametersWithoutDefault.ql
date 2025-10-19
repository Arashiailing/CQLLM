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

// 定义查询：获取所有Python函数并计算其无默认值参数的数量
from FunctionMetrics functionObj
// 选择函数及其无默认值参数数量，并按数量降序排序
select functionObj, 
       functionObj.getNumberOfParametersWithoutDefault() as paramCountWithoutDefault 
order by paramCountWithoutDefault desc