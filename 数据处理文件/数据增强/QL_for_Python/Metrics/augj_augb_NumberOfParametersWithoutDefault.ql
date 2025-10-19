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

import python  // 导入Python分析库以支持Python代码的静态分析

// 定义查询：从FunctionMetrics类中获取函数对象并计算非默认参数数量
from FunctionMetrics func
// 计算每个函数中缺少默认值的参数数量
where exists(func.getNumberOfParametersWithoutDefault())
// 选择函数对象及其非默认参数计数，按计数降序排列
select func, func.getNumberOfParametersWithoutDefault() as nonDefaultParamCount 
order by nonDefaultParamCount desc