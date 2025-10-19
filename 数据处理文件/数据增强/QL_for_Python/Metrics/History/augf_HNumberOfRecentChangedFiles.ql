/**
 * @name 最近更改的文件
 * @description 最近编辑的文件数量
 * @kind treemap
 * @id py/historical-number-of-recent-changed-files
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// 查找在最近半年内有提交记录的Python模块
from Module moduleObj
where
  // 检查该模块是否有相关的版本控制提交记录
  exists(Commit commitEntry |
    // 提交记录影响了当前模块的文件
    commitEntry.getAnAffectedFile() = moduleObj.getFile() and
    // 提交时间在最近180天内（约半年）
    commitEntry.daysToNow() <= 180 and
    // 排除非实质性的人工更改（如格式化、重构等）
    not artificialChange(commitEntry)
  ) and
  // 确保模块有可度量的代码行数（排除空文件或配置文件）
  exists(moduleObj.getMetrics().getNumberOfLinesOfCode())
// 输出符合条件的模块及其计数（用于树状图可视化）
select moduleObj, 1