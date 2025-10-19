/**
 * @name Count of non-default parameters
 * @description 统计函数中未设置默认值的参数的数量。
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 引入Python语言分析模块，用于对Python代码结构进行静态分析

// 从函数度量集合中获取所有需要分析的函数
from FunctionMetrics analyzedFunction
// 提取每个函数及其无默认值参数的统计信息，并按照参数数量从高到低排序
select analyzedFunction, 
       analyzedFunction.getNumberOfParametersWithoutDefault() as paramsWithoutDefaultCount 
order by paramsWithoutDefaultCount desc