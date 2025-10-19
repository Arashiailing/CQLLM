/**
 * @name Non-default Parameter Count Analysis
 * @description This query identifies and counts function parameters that do not have default value assignments.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 导入Python模块，用于支持Python代码的静态分析功能

// 定义函数对象作为分析目标
from FunctionMetrics functionObj
// 确保函数具有可分析的参数结构
where exists(functionObj.getNumberOfParametersWithoutDefault())
// 选择函数及其无默认值参数数量统计
select functionObj, 
       functionObj.getNumberOfParametersWithoutDefault() as paramCountNoDefault 
// 按无默认值参数数量降序排列结果
order by paramCountNoDefault desc