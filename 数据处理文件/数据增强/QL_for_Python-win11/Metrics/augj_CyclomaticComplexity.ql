/**
 * @name Cyclomatic complexity of functions
 * @description The cyclomatic complexity per function (an indication of how many tests are necessary,
 *              based on the number of branching statements).
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

// 分析函数的圈复杂度：圈复杂度是衡量代码复杂度的指标，
// 表示通过代码的独立路径数量，影响测试用例的需求量
from Function method, int complexityScore
where complexityScore = method.getMetrics().getCyclomaticComplexity()
// 输出函数及其圈复杂度评分，按复杂度从高到低排序，
// 便于识别需要重构或额外测试的复杂函数
select method, complexityScore order by complexityScore desc