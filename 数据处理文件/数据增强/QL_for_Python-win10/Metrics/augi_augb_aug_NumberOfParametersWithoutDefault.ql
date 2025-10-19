/**
 * @name Number of parameters without defaults
 * @description Identifies and counts parameters in Python functions that do not have default values,
 *              which can indicate higher complexity and reduced testability.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 引入Python分析模块，提供对Python代码的静态分析能力

// 从FunctionMetrics类中检索所有Python函数进行分析
from FunctionMetrics analyzedFunction
// 计算每个函数中无默认值的参数数量，这些参数是调用时必须提供的
select analyzedFunction, 
       analyzedFunction.getNumberOfParametersWithoutDefault() as nonDefaultParamCount 
// 按无默认值参数数量降序排序，优先显示复杂度较高的函数
order by nonDefaultParamCount desc