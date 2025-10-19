/**
 * @name Count of non-default parameters
 * @description This metric quantifies the number of function parameters that are not assigned default values.
 *              Functions with many non-default parameters may be harder to test and maintain.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 导入Python分析库，提供Python代码的静态分析能力

// 获取所有函数的度量数据，这些数据包含了函数的各种统计信息
from FunctionMetrics measuredFunction
// 选择函数对象及其无默认值的参数计数，并按计数降序排列以便优先展示参数较多的函数
select measuredFunction, measuredFunction.getNumberOfParametersWithoutDefault() as paramCount order by paramCount desc