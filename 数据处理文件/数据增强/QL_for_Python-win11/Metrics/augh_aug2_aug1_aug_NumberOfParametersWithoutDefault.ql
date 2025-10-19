/**
 * @name Count of non-default parameters
 * @description 计算函数中未分配默认值的参数数量。
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 引入Python语言分析模块，用于静态分析Python代码结构

// 从函数度量集合中检索所有需要分析的函数
from FunctionMetrics targetFunction
// 提取每个函数及其无默认值参数的统计信息，并按照参数数量降序排序
select targetFunction, 
       targetFunction.getNumberOfParametersWithoutDefault() as nonDefaultParamsCount 
order by nonDefaultParamsCount desc