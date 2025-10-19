/**
 * @name Number of parameters without defaults
 * @description Calculates the count of function parameters that lack default value assignments.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 导入Python模块以进行代码静态分析

// 选择所有Python函数并计算其无默认值参数的数量
from FunctionMetrics func
select func, 
       func.getNumberOfParametersWithoutDefault() as nonDefaultParamCount 
// 按无默认值参数数量从高到低排序结果
order by nonDefaultParamCount desc