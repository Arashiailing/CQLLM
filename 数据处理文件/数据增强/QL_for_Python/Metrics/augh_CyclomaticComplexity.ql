/**
 * @name Cyclomatic complexity of functions
 * @description Measures the cyclomatic complexity for each Python function (indicating the number of
 *              independent paths through the function's code, which correlates with testing effort).
 * @kind treemap
 * @id py/cyclomatic-complexity-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max sum
 * @tags testability
 *       complexity
 *       maintainability
 */

import python

// 查询每个函数的圈复杂度值
from Function callableUnit, int cyclomaticValue
// 获取函数的度量指标，并提取其中的圈复杂度值
where cyclomaticValue = callableUnit.getMetrics().getCyclomaticComplexity()
// 输出函数及其对应的圈复杂度，按复杂度从高到低排序
select callableUnit, cyclomaticValue order by cyclomaticValue desc