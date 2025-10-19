/**
 * @name 最近更改的文件
 * @description 识别在过去半年内被非人工提交修改过的Python模块文件
 * @kind treemap
 * @id py/historical-number-of-recent-changed-files
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// 定义查询目标：Python源代码模块
from Module pythonModule

where
  // 条件1：模块文件在过去180天内被非人工提交修改过
  exists(Commit recentCommit |
    recentCommit.getAnAffectedFile() = pythonModule.getFile() and
    recentCommit.daysToNow() <= 180 and
    not artificialChange(recentCommit)
  )
  and
  // 条件2：模块具有可度量的代码行数
  exists(pythonModule.getMetrics().getNumberOfLinesOfCode())

// 输出结果：符合条件的模块和固定值1
select pythonModule, 1