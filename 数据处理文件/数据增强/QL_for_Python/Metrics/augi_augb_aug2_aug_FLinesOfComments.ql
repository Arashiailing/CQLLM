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

import python // 导入Python语言分析库，用于访问Python代码的语法结构和度量信息

// 遍历所有Python源文件，统计每个文件中注释的总行数
// 注释统计包括：单行/多行注释、文档字符串(docstrings)
from Module sourceFile, int commentLineCount
where
  // 计算总注释行数：常规注释行数加上文档字符串行数
  commentLineCount = 
    sourceFile.getMetrics().getNumberOfLinesOfComments() + 
    sourceFile.getMetrics().getNumberOfLinesOfDocStrings()
select sourceFile, commentLineCount order by commentLineCount desc