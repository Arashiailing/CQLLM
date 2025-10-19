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

// 查询所有Python模块，筛选出满足以下两个条件的模块：
from Module pythonModule
where
  // 条件1：模块必须包含可度量的代码行数（即非空文件）
  exists(pythonModule.getMetrics().getNumberOfLinesOfCode()) and
  // 条件2：模块在过去180天内存在真实的代码更改提交记录
  exists(Commit recentCommitRecord |
    // 提交记录影响了当前模块的文件
    recentCommitRecord.getAnAffectedFile() = pythonModule.getFile() and
    // 提交发生在过去180天内
    recentCommitRecord.daysToNow() <= 180 and
    // 排除人工更改（如格式化、重构等非功能性更改）
    not artificialChange(recentCommitRecord)
  )
// 输出符合条件的模块及计数（用于treemap可视化展示）
select pythonModule, 1