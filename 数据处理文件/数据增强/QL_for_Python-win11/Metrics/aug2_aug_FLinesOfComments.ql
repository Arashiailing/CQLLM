/**
 * @name File Comment Line Count
 * @kind treemap
 * @description Calculates the total comment lines per file (including docstrings,
 *              excluding pure code lines and blank lines).
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/lines-of-comments-in-files
 */

import python // 导入Python模块，用于分析Python代码结构

// 从每个Python模块中提取文件，并计算其注释和文档字符串的总行数
from Module pyModule, int commentLineCount
where
  // 获取模块的常规注释行数
  commentLineCount = pyModule.getMetrics().getNumberOfLinesOfComments() and
  // 添加文档字符串行数到总计中
  commentLineCount = commentLineCount + pyModule.getMetrics().getNumberOfLinesOfDocStrings()
select pyModule, commentLineCount order by commentLineCount desc