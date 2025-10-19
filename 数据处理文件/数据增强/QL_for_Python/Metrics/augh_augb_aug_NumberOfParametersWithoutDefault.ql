/**
 * @name Number of parameters without defaults
 * @description Analyzes Python functions to count parameters that lack default values,
 *              which may indicate higher complexity and reduced testability.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 导入Python模块，支持Python代码的静态分析

// 定义查询范围：分析所有Python函数的参数特征
from FunctionMetrics analyzedFunction
// 选择函数及其无默认值参数计数，用于复杂度评估
select analyzedFunction, 
       analyzedFunction.getNumberOfParametersWithoutDefault() as mandatoryParamCount 
// 按必需参数数量降序排列，优先展示高复杂度函数
order by mandatoryParamCount desc