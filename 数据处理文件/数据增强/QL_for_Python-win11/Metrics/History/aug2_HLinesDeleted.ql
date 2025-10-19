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

// 定义文件删除行数统计变量
from Module sourceModule, int totalDeletedLines
where
  // 确保模块有代码行数的度量数据
  exists(sourceModule.getMetrics().getNumberOfLinesOfCode()) and
  // 计算每个文件在版本历史中的总删除行数
  totalDeletedLines = 
    sum(Commit revision, int deletedCount |
      // 获取指定文件在最近提交中的删除行数，排除人工变更
      deletedCount = revision.getRecentDeletionsForFile(sourceModule.getFile()) and 
      not artificialChange(revision)
    |
      deletedCount  // 累加每个提交中的删除行数
    )
select sourceModule, totalDeletedLines order by totalDeletedLines desc