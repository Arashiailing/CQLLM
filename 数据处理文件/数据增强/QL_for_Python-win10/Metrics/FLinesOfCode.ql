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

import python // 导入python库，用于分析Python代码

// 定义查询语句，从Module m中选择文件模块，并计算其代码行数n
from Module m, int n
where n = m.getMetrics().getNumberOfLinesOfCode() // 获取每个文件的代码行数，忽略仅包含文档字符串、注释或空行的行
select m, n order by n desc // 按代码行数降序排列结果
