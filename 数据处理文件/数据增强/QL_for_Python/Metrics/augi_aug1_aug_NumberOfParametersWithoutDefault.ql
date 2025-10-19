/**
 * @name Function Parameter Default Value Analysis
 * @description Measures the count of function parameters that are not assigned default values.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 导入Python模块，提供Python代码的静态分析能力

// 分析目标：从函数度量中提取所有函数
from FunctionMetrics analyzedFunction
// 输出结果：函数及其无默认值参数的数量
select analyzedFunction, 
       analyzedFunction.getNumberOfParametersWithoutDefault() as paramWithoutDefaultCount 
// 排序规则：按无默认值参数数量降序排列
order by paramWithoutDefaultCount desc