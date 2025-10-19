/**
 * @name Number of parameters without defaults
 * @description Counts parameters in functions that lack default value assignments.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 引入Python模块，用于分析Python源代码中的函数参数

// 查询FunctionMetrics类以获取函数及其无默认值的参数计数
from FunctionMetrics functionObj, int paramCount
where paramCount = functionObj.getNumberOfParametersWithoutDefault()
select functionObj, paramCount order by paramCount desc
// 输出函数functionObj及其无默认值的参数数量paramCount，结果按paramCount值降序排序