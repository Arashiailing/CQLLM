/**
 * @name 最近修改的代码文件
 * @description 检测最近半年内经人工提交修改的Python模块文件
 * @details 本查询通过分析版本控制历史，识别在过去180天内由真实开发人员提交修改的Python源代码模块，
 *          过滤掉自动化或系统生成的变更，专注于统计由开发人员维护的代码文件。
 * @kind treemap
 * @id py/historical-number-of-recent-changed-files
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// 定义查询目标：Python源代码模块
from Module targetModule

where
  // 确保模块具有可度量的代码行数
  exists(targetModule.getMetrics().getNumberOfLinesOfCode())
  and
  // 检查模块在过去180天内是否被非人工提交修改过
  exists(Commit changeCommit |
    changeCommit.getAnAffectedFile() = targetModule.getFile() and
    changeCommit.daysToNow() <= 180 and
    not artificialChange(changeCommit)
  )

// 输出结果：符合条件的模块和固定值1
select targetModule, 1