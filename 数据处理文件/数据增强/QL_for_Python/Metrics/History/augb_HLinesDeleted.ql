/**
 * @name Deleted lines per file
 * @description Number of deleted lines per file, across the revision history in the database.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

from Module fileModule, int totalDeletedLines
where
  // 确保模块有代码行数的度量数据
  exists(fileModule.getMetrics().getNumberOfLinesOfCode()) and
  // 计算每个文件在版本历史中的删除行数总和
  totalDeletedLines =
    sum(Commit revision, int linesRemoved |
      // 获取每个版本提交中文件的删除行数，排除人工变更
      linesRemoved = revision.getRecentDeletionsForFile(fileModule.getFile()) and 
      not artificialChange(revision)
    |
      linesRemoved
    )
select fileModule, totalDeletedLines order by totalDeletedLines desc