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

// 查询最近180天内的有效代码提交
from Commit recentCommit
where recentCommit.daysToNow() <= 180  // 时间范围：最近半年
  and not artificialChange(recentCommit)  // 排除自动生成的更改
select recentCommit.getRevisionName(), 1  // 返回修订标识和计数