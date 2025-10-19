/**
 * @name 最近更改的文件
 * @description 检测在过去180天内被非人工提交修改过的Python模块文件
 * @kind treemap
 * @id py/historical-number-of-recent-changed-files
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// 查询所有满足以下条件的Python源代码模块：
from Module sourceModule
where
  // 条件1：模块文件在过去180天内被提交修改过
  exists(Commit commitEntry |
    commitEntry.getAnAffectedFile() = sourceModule.getFile() and
    commitEntry.daysToNow() <= 180 and
    not artificialChange(commitEntry)
  ) and
  // 条件2：模块具有可度量的代码行数
  exists(sourceModule.getMetrics().getNumberOfLinesOfCode())
select sourceModule, 1