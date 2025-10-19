/**
 * @name Count of non-default parameters
 * @description 分析并计算每个函数定义中未提供默认值的参数数量。
 *              该指标可用于评估函数的复杂性和可测试性。
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // 引入Python静态分析核心模块，提供代码分析基础能力

// 定义查询目标：从函数度量数据中提取分析对象
from FunctionMetrics targetFunction
// 计算并选择目标函数及其无默认值参数数量
where exists(targetFunction.getNumberOfParametersWithoutDefault())
select targetFunction, 
       targetFunction.getNumberOfParametersWithoutDefault() as nonDefaultParamCount 
order by nonDefaultParamCount desc