/**
 * @name Number of parameters without defaults
 * @description Analyzes Python functions to count parameters that lack default values.
 *              Functions with many non-default parameters tend to be more complex and
 *              harder to test, as they require more arguments to be provided during invocation.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 导入Python模块，提供Python代码的静态分析能力

// 查询所有Python函数，评估其接口复杂度
from FunctionMetrics functionUnderTest
// 计算每个函数中需要显式传递的参数数量（没有默认值的参数）
select functionUnderTest, 
       functionUnderTest.getNumberOfParametersWithoutDefault() as mandatoryParamCount 
// 按必需参数数量降序排列，优先显示具有高接口复杂度的函数
order by mandatoryParamCount desc