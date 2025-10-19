/**
 * @name Number of lines
 * @description The number of lines in each file.
 * @kind treemap
 * @id py/lines-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python // 导入python模块，用于分析Python代码

// 从Module m和int n中进行选择
from Module m, int n
// 条件：n等于m的行数
where n = m.getMetrics().getNumberOfLines()
// 选择m和n，并按n降序排列
select m, n order by n desc
