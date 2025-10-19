/**
 * @name Lines of code in functions
 * @description Calculates and displays the number of lines of code for each function.
 * @kind treemap
 * @id py/lines-of-code-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // 导入python模块，用于处理Python代码分析

// 定义变量func表示每个Python函数
// 计算每个函数的代码行数并存储为linesCount
// 按代码行数降序排列结果
from Function func
select func, func.getMetrics().getNumberOfLinesOfCode() as linesCount order by linesCount desc