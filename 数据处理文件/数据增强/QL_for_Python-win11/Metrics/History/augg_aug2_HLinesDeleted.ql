/**
 * @name File Deletion Count
 * @description Tracks the cumulative count of lines removed from each file throughout the entire revision history.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

// 定义变量：目标文件和累计删除行数
from Module targetFile, int cumulativeDeletions
where
  // 确保目标文件有可度量的代码行数
  exists(targetFile.getMetrics().getNumberOfLinesOfCode()) and
  // 计算累计删除行数
  cumulativeDeletions = sum(Commit commitRecord, int linesRemoved |
    // 获取每次提交中对目标文件的删除行数
    linesRemoved = commitRecord.getRecentDeletionsForFile(targetFile.getFile()) and 
    // 排除人工变更
    not artificialChange(commitRecord)
  |
    linesRemoved  // 累加所有提交中的删除行数
  )
// 输出结果：文件及其累计删除行数，按删除行数降序排列
select targetFile, cumulativeDeletions order by cumulativeDeletions desc