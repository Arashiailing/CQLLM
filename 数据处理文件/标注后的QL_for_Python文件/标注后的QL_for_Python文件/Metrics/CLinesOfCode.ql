/**
 * @name Lines of code in functions
 * @description The number of lines of code in a function.
 * @kind treemap
 * @id py/lines-of-code-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // 导入python模块，用于处理Python代码

// 从Function类中选择函数f和其代码行数作为n，并按n降序排列
from Function f
select f, f.getMetrics().getNumberOfLinesOfCode() as n order by n desc
