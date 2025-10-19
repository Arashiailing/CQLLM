/**
 * @name Count of comment lines in source files
 * @kind treemap
 * @description Computes the aggregate count of comment lines per source file, 
 *              including both standard comments and docstrings, while excluding
 *              blank lines and pure code lines.
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/lines-of-comments-in-files
 */

import python // 导入python模块，用于分析Python源代码

// 从每个模块（文件）中提取数据，并计算其注释和文档字符串的总行数
from Module fileModule, int totalCommentLines
where
  // 计算每个模块的注释行数（包括常规注释和文档字符串）
  totalCommentLines = fileModule.getMetrics().getNumberOfLinesOfComments() + 
                      fileModule.getMetrics().getNumberOfLinesOfDocStrings()
select fileModule, totalCommentLines order by totalCommentLines desc // 输出模块及其注释总行数，并按注释行数降序排列