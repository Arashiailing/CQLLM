/**
 * @name Number of parameters without defaults
 * @description Counts the parameters in each function that are not assigned default values.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 导入Python分析库，提供处理Python代码的基础功能

// 遍历所有函数对象，计算每个函数中未定义默认值的参数数量
from FunctionMetrics functionObj
select functionObj, functionObj.getNumberOfParametersWithoutDefault() as nonDefaultParamCount order by nonDefaultParamCount desc
// 输出函数对象及其无默认值的参数计数，按计数从高到低排序