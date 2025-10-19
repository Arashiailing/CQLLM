/**
 * @name Percentage of comments
 * @description The percentage of lines in a file that contain comments. Note that docstrings are
 *              reported by a separate metric.
 * @kind treemap
 * @id py/comment-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python  // 导入Python库，用于分析Python代码

// 从Module和ModuleMetrics中选择数据
from Module m, ModuleMetrics mm
where mm = m.getMetrics() and mm.getNumberOfLines() > 0  // 过滤条件：模块的行数大于0
select m, 100.0 * (mm.getNumberOfLinesOfComments().(float) / mm.getNumberOfLines().(float)) as ratio  // 计算注释行数占总行数的百分比
  order by ratio desc  // 按比例降序排列结果
