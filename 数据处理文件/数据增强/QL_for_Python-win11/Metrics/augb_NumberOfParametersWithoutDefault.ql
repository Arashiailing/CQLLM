/**
 * @name Count of non-default parameters
 * @description Measures how many function parameters lack default value assignments.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 引入Python分析库以支持Python代码的静态分析

// 从FunctionMetrics类中提取函数对象
from FunctionMetrics functionObj
// 选择函数对象及其无默认值的参数计数，按计数降序排列
select functionObj, functionObj.getNumberOfParametersWithoutDefault() as paramCount order by paramCount desc