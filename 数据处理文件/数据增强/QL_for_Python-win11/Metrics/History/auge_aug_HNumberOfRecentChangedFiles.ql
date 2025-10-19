/**
 * @name 最近修改的模块
 * @description 识别在过去180天内由非人工提交更改的Python模块文件
 * @kind treemap
 * @id py/historical-number-of-recent-changed-files
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// 查找满足以下条件的Python模块：
from Module targetModule
where
  // 条件1：模块必须包含可度量的代码行数
  exists(targetModule.getMetrics().getNumberOfLinesOfCode()) and
  // 条件2：模块文件在指定时间范围内被非人工提交修改
  exists(Commit commitRecord |
    commitRecord.getAnAffectedFile() = targetModule.getFile() and
    commitRecord.daysToNow() <= 180 and
    not artificialChange(commitRecord)
  )
select targetModule, 1