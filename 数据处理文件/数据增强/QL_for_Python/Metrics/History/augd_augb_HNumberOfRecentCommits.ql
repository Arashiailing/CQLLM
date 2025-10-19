/**
 * @name 近期代码提交分析
 * @description 分析并统计过去180天内非人工干预的代码提交数量
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python
import external.VCS

// 查询目标：筛选符合条件的版本控制提交记录
from Commit recentCommit
// 筛选条件：限制时间范围并排除人工更改
where 
  // 时间范围限制：仅考虑最近180天内的提交
  recentCommit.daysToNow() <= 180
  and 
  // 排除条件：过滤掉由自动化工具或系统生成的提交
  not artificialChange(recentCommit)
// 结果输出：返回提交的修订标识符和计数值（用于后续聚合统计）
select recentCommit.getRevisionName(), 1