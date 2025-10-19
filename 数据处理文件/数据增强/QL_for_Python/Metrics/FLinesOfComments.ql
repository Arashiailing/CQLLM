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

import python // 导入python模块，用于处理Python代码

// 从Module m中选择文件，并计算其注释行数和文档字符串行数的总和
from Module m, int n
where
  // 获取文件中的注释行数和文档字符串行数，并将其相加赋值给n
  n = m.getMetrics().getNumberOfLinesOfComments() + m.getMetrics().getNumberOfLinesOfDocStrings()
select m, n order by n desc // 选择文件m和计算得到的注释行数n，并按n降序排列
