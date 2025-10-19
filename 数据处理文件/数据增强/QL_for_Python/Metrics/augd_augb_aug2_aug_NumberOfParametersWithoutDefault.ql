/**
 * @name Count of Mandatory Parameters
 * @description Computes the number of function parameters that do not have default values.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 引入Python分析模块以支持静态代码分析

// 查询逻辑：识别Python函数并统计其必须提供的参数数量
from FunctionMetrics callableEntity
// 输出结果：函数对象及其必须参数计数，按参数数量从多到少排序
select callableEntity, 
       callableEntity.getNumberOfParametersWithoutDefault() as mandatoryParamCount 
order by mandatoryParamCount desc