/**
 * @name Deleted lines per file
 * @description Calculates the total number of lines deleted per file throughout 
 *              the revision history. This metric helps identify files that have 
 *              undergone significant refactoring or removal of code.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

from Module pythonModule, int totalDeletedLines
where
  // 计算每个文件在版本控制历史中被删除的总行数
  totalDeletedLines =
    sum(Commit commitEntry, int deletedCount |
      // 获取最近一次提交中指定文件的删除行数，并排除人工变更
      deletedCount = commitEntry.getRecentDeletionsForFile(pythonModule.getFile()) and 
      not artificialChange(commitEntry)
    |
      deletedCount
    ) and
  // 确保模块有代码行数的度量数据
  exists(pythonModule.getMetrics().getNumberOfLinesOfCode())
select pythonModule, totalDeletedLines order by totalDeletedLines desc