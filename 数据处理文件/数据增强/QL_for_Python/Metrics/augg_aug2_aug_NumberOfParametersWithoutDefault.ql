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

// 从函数指标数据源中提取每个可调用实体，并统计其无默认值的参数数量
from FunctionMetrics callableEntity
select callableEntity, 
       callableEntity.getNumberOfParametersWithoutDefault() as paramWithoutDefaultCount 
order by paramWithoutDefaultCount desc  // 根据无默认值参数数量降序排列结果