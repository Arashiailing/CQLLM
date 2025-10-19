/**
 * @name Count of Mandatory Parameters
 * @description Calculates the quantity of function parameters that are required (without default values).
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 导入Python分析模块以启用静态代码分析功能

// 查询实现：遍历Python函数并计算每个函数的必需参数个数
from FunctionMetrics functionObj
// 输出格式：函数实体及其必需参数计数，结果按参数数量降序排列
select functionObj, 
       functionObj.getNumberOfParametersWithoutDefault() as requiredParamCount 
order by requiredParamCount desc