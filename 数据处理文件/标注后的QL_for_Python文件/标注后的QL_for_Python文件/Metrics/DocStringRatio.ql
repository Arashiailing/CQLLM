/**
 * @name Percentage of docstrings
 * @description The percentage of lines in a file that contain docstrings.
 * @kind treemap
 * @id py/doc-string-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

// 从模块和模块度量中选择数据，其中模块的行数大于0
from Module m, ModuleMetrics mm
where mm = m.getMetrics() and mm.getNumberOfLines() > 0
select m,
  // 计算包含文档字符串的行数占文件总行数的百分比，并按比例降序排列
  100.0 * (mm.getNumberOfLinesOfDocStrings().(float) / mm.getNumberOfLines().(float)) as ratio
order by ratio desc
