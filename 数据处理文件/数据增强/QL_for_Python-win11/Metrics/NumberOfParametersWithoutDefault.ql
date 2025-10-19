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

import python  // 导入Python库，用于处理Python代码的查询

// 从FunctionMetrics类中选择函数和没有默认值的参数数量
from FunctionMetrics func
select func, func.getNumberOfParametersWithoutDefault() as n order by n desc
// 选择函数func和其没有默认值的参数数量n，并按n降序排列
