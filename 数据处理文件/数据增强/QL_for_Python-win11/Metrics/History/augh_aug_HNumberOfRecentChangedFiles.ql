/**
 * @name 最近更改的文件
 * @description 识别在过去180天内由非人工提交修改的Python模块文件
 * @kind treemap
 * @id py/historical-number-of-recent-changed-files
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

from Module changedModule
where
  // 检查模块文件存在有效代码行数
  exists(changedModule.getMetrics().getNumberOfLinesOfCode()) and
  // 验证存在符合时间要求的非人工提交
  exists(Commit recentCommit |
    recentCommit.getAnAffectedFile() = changedModule.getFile() and
    recentCommit.daysToNow() <= 180 and
    not artificialChange(recentCommit)
  )
select changedModule, 1