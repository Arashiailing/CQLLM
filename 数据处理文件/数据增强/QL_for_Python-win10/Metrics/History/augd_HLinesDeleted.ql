/**
 * @name Deleted lines per file
 * @description Calculates the total number of lines deleted per file throughout 
 *              the entire revision history stored in the database.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python // Python模块，提供Python代码分析功能
import external.VCS // 外部版本控制模块，用于访问代码版本历史数据

// 从源文件和删除行数计数中提取数据
from Module sourceFile, int deletedLinesCount
where
  // 计算每个源文件在所有提交中的删除行数总和
  deletedLinesCount =
    sum(Commit commitRecord, int deletedLines |
      // 获取每个提交记录中对应文件的删除行数，并过滤掉非人工变更
      deletedLines = commitRecord.getRecentDeletionsForFile(sourceFile.getFile()) 
      and not artificialChange(commitRecord)
    |
      deletedLines // 聚合每个提交的删除行数
    ) and
  // 确保源文件具有有效的代码行数度量数据
  exists(sourceFile.getMetrics().getNumberOfLinesOfCode())
select sourceFile, deletedLinesCount order by deletedLinesCount desc // 按删除行数降序排列结果