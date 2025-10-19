/**
 * @name File Comment Line Count
 * @kind treemap
 * @description Computes the aggregate number of comment lines for each Python file.
 *              This includes both inline comments and docstrings, while excluding
 *              pure code lines and blank lines.
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/lines-of-comments-in-files
 */

import python // 导入Python模块，用于分析Python代码结构

// 从Python模块中提取文件，并计算其注释和文档字符串的总行数
from Module pythonModule, int totalCommentLines
where
  // 计算模块中的常规注释行数
  exists(int regularComments |
    regularComments = pythonModule.getMetrics().getNumberOfLinesOfComments() and
    // 计算模块中的文档字符串行数
    exists(int docStringLines |
      docStringLines = pythonModule.getMetrics().getNumberOfLinesOfDocStrings() and
      // 总注释行数为常规注释与文档字符串之和
      totalCommentLines = regularComments + docStringLines
    )
  )
select pythonModule, totalCommentLines order by totalCommentLines desc