/**
 * @name Number of recent authors
 * @description Number of distinct authors that have recently made changes
 * @kind treemap
 * @id py/historical-number-of-recent-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python // 导入python库，用于处理Python代码
import external.VCS // 导入外部版本控制系统（VCS）库，用于访问版本控制信息

// 从模块m中选择数据
from Module m
// 条件：模块m存在行数度量指标
where exists(m.getMetrics().getNumberOfLinesOfCode())
// 选择模块m和最近180天内有提交的作者数量
select m,
  count(Author author |
    // 条件：存在一个提交e满足以下条件
    exists(Commit e |
      e = author.getACommit() and // 提交e是作者author的一个提交
      m.getFile() = e.getAnAffectedFile() and // 提交e影响了模块m的文件
      e.daysToNow() <= 180 and // 提交e在最近180天内
      not artificialChange(e) // 提交e不是人工变更
    )
  )
