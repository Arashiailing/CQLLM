/**
 * @name File-wise deletion statistics
 * @description Aggregates the cumulative count of removed lines for each file 
 *              across the complete version history maintained in the database.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python // Python模块，提供Python代码分析功能
import external.VCS // 外部版本控制模块，用于访问代码版本历史数据

// 提取模块文件及其对应的总删除行数
from Module codeModule, int totalRemovedLines
where
  // 确保模块具有可度量的代码行数
  exists(codeModule.getMetrics().getNumberOfLinesOfCode()) and
  // 计算该模块在所有版本提交中的累计删除行数
  totalRemovedLines =
    sum(Commit versionCommit, int linesRemoved |
      // 获取每次提交中对应文件的删除行数，并排除自动生成的变更
      linesRemoved = versionCommit.getRecentDeletionsForFile(codeModule.getFile()) 
      and not artificialChange(versionCommit)
    |
      linesRemoved // 累计每次提交的删除行数
    )
select codeModule, totalRemovedLines order by totalRemovedLines desc // 按总删除行数降序排列结果