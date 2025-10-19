/**
 * @name Count of non-default parameters
 * @description Calculates how many function parameters lack default value assignments.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 导入Python模块，用于支持Python代码的静态分析功能

// 获取所有函数作为分析对象
from FunctionMetrics func
// 选择函数及其无默认值的参数计数
select func, 
       func.getNumberOfParametersWithoutDefault() as nonDefaultParamCount 
// 按无默认值参数数量降序排序
order by nonDefaultParamCount desc