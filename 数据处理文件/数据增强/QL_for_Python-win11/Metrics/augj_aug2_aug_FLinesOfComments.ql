/**
 * @name File Comment Line Count
 * @kind treemap
 * @description Computes the aggregate count of comment lines in each file (encompassing
 *              docstrings, while excluding pure code lines and blank lines).
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/lines-of-comments-in-files
 */

import python // 导入Python模块，用于分析Python代码结构

// 从每个Python模块中提取文件，并计算其注释和文档字符串的总行数
from Module pythonFile, int totalCommentLines
where
  // 计算常规注释行数
  totalCommentLines = pythonFile.getMetrics().getNumberOfLinesOfComments() and
  // 累加文档字符串行数
  totalCommentLines = totalCommentLines + pythonFile.getMetrics().getNumberOfLinesOfDocStrings()
select pythonFile, totalCommentLines order by totalCommentLines desc