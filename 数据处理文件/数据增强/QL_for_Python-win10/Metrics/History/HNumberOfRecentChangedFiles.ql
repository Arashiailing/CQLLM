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

// 从模块 m 中选择文件，并满足以下条件：
from Module m
where
  // 存在一个提交 e，使得 e 影响的文件是 m 的文件，并且 e 的天数距离现在不超过 180 天，且不是人工更改
  exists(Commit e |
    e.getAnAffectedFile() = m.getFile() and e.daysToNow() <= 180 and not artificialChange(e)
  ) and
  // 存在 m 的度量指标中的代码行数
  exists(m.getMetrics().getNumberOfLinesOfCode())
select m, 1
