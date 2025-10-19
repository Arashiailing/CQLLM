/**
 * @name File Comment Line Count
 * @kind treemap
 * @description Computes the cumulative count of comment lines in each file,
 *              encompassing both standard comments and docstrings, while
 *              excluding pure code lines and empty lines.
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/lines-of-comments-in-files
 */

import python // 引入Python分析工具包，用于解析Python代码结构

// 遍历所有Python源文件，统计每个文件中的注释总行数
// 注释类型包括：常规注释行和文档字符串行
from Module sourceModule, int commentLineCount
where
  // 计算注释总行数：常规注释行数与文档字符串行数之和
  commentLineCount = 
    sourceModule.getMetrics().getNumberOfLinesOfComments() + 
    sourceModule.getMetrics().getNumberOfLinesOfDocStrings()
select sourceModule, commentLineCount order by commentLineCount desc