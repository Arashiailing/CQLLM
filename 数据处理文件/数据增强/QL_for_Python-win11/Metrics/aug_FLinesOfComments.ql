/**
 * @name Lines of comments in files
 * @kind treemap
 * @description Measures the number of lines of comments in each file (including docstrings,
 *              and ignoring lines that contain only code or are blank).
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/lines-of-comments-in-files
 */

import python // 导入Python模块，用于分析Python代码结构

// 从每个Python模块中提取文件，并计算其注释和文档字符串的总行数
from Module sourceFile, int totalCommentLines
where
  // 计算文件的注释行数（包括常规注释和文档字符串）
  totalCommentLines = 
    sourceFile.getMetrics().getNumberOfLinesOfComments() + 
    sourceFile.getMetrics().getNumberOfLinesOfDocStrings()
select sourceFile, totalCommentLines order by totalCommentLines desc