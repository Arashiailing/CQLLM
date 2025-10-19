/**
 * @name Deleted lines per file
 * @description Number of deleted lines per file, across the revision history in the database.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

// 查询变量声明：目标模块及其累计删除行数
from Module codeModule, int cumulativeDeletions
where
  // 确保模块具有可度量的代码行数
  exists(codeModule.getMetrics().getNumberOfLinesOfCode()) and
  // 计算该模块在版本控制历史中的总删除行数
  cumulativeDeletions = 
    sum(Commit commit, int deletionCount |
      // 获取特定提交中对应文件的删除行数
      deletionCount = commit.getRecentDeletionsForFile(codeModule.getFile()) and 
      // 排除人工变更或自动生成的提交
      not artificialChange(commit)
    |
      deletionCount  // 累加每次提交的删除行数
    )
select codeModule, cumulativeDeletions order by cumulativeDeletions desc