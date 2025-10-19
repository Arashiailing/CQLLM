/**
 * @name Churned lines per file
 * @description Number of churned lines per file, across the revision history in the database.
 * @kind treemap
 * @id py/historical-churn
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

// 导入python模块
import python
// 导入外部版本控制系统（VCS）模块
import external.VCS

// 从Module m和整数n中选择数据
from Module m, int n
where
  // 计算每个文件的变更行数，并存储在变量n中
  n =
    sum(Commit entry, int churn |
      // 获取最近一次提交中文件的变更行数，并且过滤掉人工更改的提交
      churn = entry.getRecentChurnForFile(m.getFile()) and not artificialChange(entry)
    |
      // 累加变更行数
      churn
    ) and
  // 确保模块有代码行数的度量指标
  exists(m.getMetrics().getNumberOfLinesOfCode())
select m, n order by n desc
// 选择模块和变更行数，并按变更行数降序排列
