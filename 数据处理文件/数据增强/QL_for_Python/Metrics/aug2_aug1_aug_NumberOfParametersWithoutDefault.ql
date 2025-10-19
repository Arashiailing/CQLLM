/**
 * @name Count of non-default parameters
 * @description 计算函数中未分配默认值的参数数量。
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 导入Python模块，提供Python代码的静态分析支持

// 获取所有待分析的函数对象
from FunctionMetrics analyzedFunction
// 选择函数及其无默认值参数计数，并按计数降序排列
select analyzedFunction, 
       analyzedFunction.getNumberOfParametersWithoutDefault() as paramsWithoutDefault 
order by paramsWithoutDefault desc