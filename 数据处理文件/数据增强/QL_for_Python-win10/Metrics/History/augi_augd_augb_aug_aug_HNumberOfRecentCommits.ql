/**
 * @name 近期代码提交活动分析
 * @description 统计最近半年内的代码提交频率
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // Python语言分析支持
import external.VCS // 版本控制系统集成模块

// 查找符合时间范围和非自动生成条件的代码提交
from Commit recentCommit
where 
  // 筛选条件1：提交发生在最近180天内（半年时间窗口）
  recentCommit.daysToNow() <= 180
  and
  // 筛选条件2：排除系统自动生成的提交
  not artificialChange(recentCommit)
select recentCommit.getRevisionName(), 1  // 输出修订标识及计数（每条提交记录计为1）