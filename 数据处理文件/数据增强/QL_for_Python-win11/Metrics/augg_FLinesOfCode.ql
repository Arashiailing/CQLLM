/**
 * @name Lines of code in files
 * @kind treemap
 * @description Measures the number of lines of code in each file (ignoring lines that
 *              contain only docstrings, comments or are blank).
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python // 引入Python分析库，用于处理Python源代码

// 查询每个文件模块中的有效代码行数（不包括纯注释、文档字符串和空行）
from Module fileModule, int codeLineCount
where 
    // 获取文件模块的度量信息，并提取有效代码行数
    codeLineCount = fileModule.getMetrics().getNumberOfLinesOfCode()
select 
    fileModule, 
    codeLineCount 
order by 
    codeLineCount desc // 根据代码行数从高到低排序