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

import python // 导入Python分析模块，提供Python代码结构分析功能

// 遍历所有Python模块，计算每个模块中的注释总行数
// 注释包括常规注释行和文档字符串行
from Module pythonModule, int totalCommentLines
where
  // 计算总注释行数：常规注释行数加上文档字符串行数
  totalCommentLines = 
    pythonModule.getMetrics().getNumberOfLinesOfComments() + 
    pythonModule.getMetrics().getNumberOfLinesOfDocStrings()
select pythonModule, totalCommentLines order by totalCommentLines desc