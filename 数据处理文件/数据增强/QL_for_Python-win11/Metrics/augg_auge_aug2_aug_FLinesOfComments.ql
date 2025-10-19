/**
 * @name Python File Comment Analysis
 * @kind treemap
 * @description Analyzes and counts the total comment lines in each Python file.
 *              Encompasses both inline comments and docstrings, while disregarding
 *              pure code lines and empty lines.
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/lines-of-comments-in-files
 */

import python // 导入Python模块，提供代码分析所需的基础功能

// 从Python代码库中识别每个模块，并计算其注释总行数
from Module pyModule, int totalComments
where
  // 计算总注释行数：常规注释行数加上文档字符串行数
  totalComments = pyModule.getMetrics().getNumberOfLinesOfComments() +
                  pyModule.getMetrics().getNumberOfLinesOfDocStrings()
select pyModule, totalComments order by totalComments desc