/**
 * @name 最近更改的文件
 * @description 检测过去180天内被修改过的Python文件
 * @kind treemap
 * @id py/historical-number-of-recent-changed-files
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// 从Python模块中选择满足以下条件的文件：
from Module pyModule
where
  // 条件1：模块具有可度量的代码行数
  exists(pyModule.getMetrics().getNumberOfLinesOfCode()) and
  // 条件2：存在近期提交记录（非人工更改）
  exists(Commit recentCommit |
    // 提交影响了当前模块的文件
    recentCommit.getAnAffectedFile() = pyModule.getFile() and
    // 提交发生在过去180天内
    recentCommit.daysToNow() <= 180 and
    // 排除人工更改
    not artificialChange(recentCommit)
  )
// 输出模块及计数（用于treemap可视化）
select pyModule, 1