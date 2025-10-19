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

// 从函数和复杂度整数中导入数据
from Function func, int complexity
// 条件：复杂度等于函数的圈复杂度度量值
where complexity = func.getMetrics().getCyclomaticComplexity()
// 选择函数和复杂度，并按复杂度降序排列
select func, complexity order by complexity desc
