/**
 * @name File Comment Line Count
 * @kind treemap
 * @description Calculates the total count of comment lines for each Python file.
 *              This metric encompasses both inline comments and docstrings,
 *              while excluding pure code lines and blank lines.
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/lines-of-comments-in-files
 */

import python

// 从Python代码库中识别模块并计算其注释行数总和
from Module pyModule, int commentLineCount
where
  // 获取模块的内联注释行数
  commentLineCount = pyModule.getMetrics().getNumberOfLinesOfComments() +
                    // 获取模块的文档字符串行数
                    pyModule.getMetrics().getNumberOfLinesOfDocStrings()
select pyModule, commentLineCount order by commentLineCount desc