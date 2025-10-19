/**
 * @name Deleted lines per file
 * @description Number of deleted lines per file, across the revision history in the database.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python // 导入python模块，用于处理Python代码相关的查询
import external.VCS // 导入外部版本控制系统（VCS）模块，用于访问版本控制数据

// 从Module m和int n中选择数据
from Module m, int n
where
  // 计算每个文件的删除行数总和，并赋值给n
  n =
    sum(Commit entry, int churn |
      // 获取最近一次提交中指定文件的删除行数，并排除人工变更
      churn = entry.getRecentDeletionsForFile(m.getFile()) and not artificialChange(entry)
    |
      // 将计算出的删除行数赋值给churn
      churn
    ) and
  // 确保模块有代码行数的度量数据
  exists(m.getMetrics().getNumberOfLinesOfCode())
select m, n order by n desc // 按删除行数降序排列结果
