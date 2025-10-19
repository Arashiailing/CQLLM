/**
 * @name Added lines per file
 * @description Number of added lines per file, across the revision history in the database.
 * @kind treemap
 * @id py/historical-lines-added
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python // 导入python模块，用于处理Python代码相关的查询
import external.VCS // 导入外部版本控制系统（VCS）模块，用于访问版本控制数据

// 从Module m和整数n中选择数据
from Module m, int n
where
  // 计算每个文件的新增行数总和，并赋值给变量n
  n =
    sum(Commit entry, int churn |
      // 获取文件在最近一次提交中的新增行数，并且过滤掉人工更改的提交
      churn = entry.getRecentAdditionsForFile(m.getFile()) and not artificialChange(entry)
    |
      // 累加新增行数
      churn
    ) and
  // 确保模块有代码行数的度量数据
  exists(m.getMetrics().getNumberOfLinesOfCode())
select m, n order by n desc // 按新增行数降序排列结果
