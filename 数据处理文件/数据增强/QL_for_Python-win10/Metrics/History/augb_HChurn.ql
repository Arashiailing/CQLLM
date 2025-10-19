/**
 * @name Churned lines per file
 * @description Number of churned lines per file, across the revision history in the database.
 * @kind treemap
 * @id py/historical-churn
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

// 导入Python语言支持模块
import python
// 导入版本控制系统集成模块
import external.VCS

// 从代码模块和变更统计值中检索数据
from Module sourceModule, int totalChurn
where
  // 计算每个模块的累计代码变更行数
  totalChurn =
    sum(Commit revision, int churnCount |
      // 获取每次提交对特定文件的代码变更量，并排除非人为的提交记录
      churnCount = revision.getRecentChurnForFile(sourceModule.getFile()) and not artificialChange(revision)
    |
      // 累加每次提交的变更行数
      churnCount
    ) and
  // 确保所选模块具有有效的代码行数统计信息
  exists(sourceModule.getMetrics().getNumberOfLinesOfCode())
// 输出模块及其对应的变更行数，按变更量从高到低排序
select sourceModule, totalChurn order by totalChurn desc