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

// 定义变量：源代码模块和总删除行数
from Module sourceModule, int totalLinesRemoved
where
  // 确保源代码模块有可度量的代码行数
  exists(sourceModule.getMetrics().getNumberOfLinesOfCode()) and
  // 计算总删除行数：遍历所有提交记录，累加每个提交中对源代码模块的删除行数
  totalLinesRemoved = sum(Commit revision, int deletedLines |
    // 获取每次提交中对源代码模块的删除行数
    deletedLines = revision.getRecentDeletionsForFile(sourceModule.getFile()) and 
    // 排除人工变更（如自动生成的提交）
    not artificialChange(revision)
  |
    deletedLines  // 累加所有提交中的删除行数
  )
// 输出结果：源代码模块及其总删除行数，按删除行数降序排列
select sourceModule, totalLinesRemoved order by totalLinesRemoved desc