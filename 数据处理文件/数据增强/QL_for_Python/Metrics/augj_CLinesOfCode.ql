/**
 * @name Function code line count
 * @description Measures the total lines of code contained within each function.
 * @kind treemap
 * @id py/lines-of-code-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // 导入python模块，用于处理Python代码分析

// 定义查询：从Function类中提取每个函数及其对应的代码行数
// 按代码行数降序排列，便于识别最复杂的函数
from Function func
where exists(func.getMetrics()) // 确保函数具有可用的度量数据
select func, func.getMetrics().getNumberOfLinesOfCode() as lineCount order by lineCount desc