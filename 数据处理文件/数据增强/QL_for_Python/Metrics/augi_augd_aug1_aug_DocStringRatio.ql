/**
 * @name Documentation String Coverage Percentage
 * @description Calculates the percentage of lines dedicated to docstrings in each Python source file.
 * @kind treemap
 * @id py/doc-string-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

// 遍历所有Python源文件模块
from Module sourceFile, ModuleMetrics metrics
where 
  // 获取每个模块的代码度量信息
  metrics = sourceFile.getMetrics() and 
  // 排除空文件以防止除零错误
  metrics.getNumberOfLines() > 0
select sourceFile,
  // 计算文档字符串覆盖率百分比： (文档字符串行数 / 总代码行数) * 100
  100.0 * (metrics.getNumberOfLinesOfDocStrings().(float) / metrics.getNumberOfLines().(float)) as coverageRatio
order by coverageRatio desc