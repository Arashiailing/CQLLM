/**
 * @name 代码提交历史统计
 * @description 统计最近180天内的代码提交活动
 * @kind treemap
 * @id py/recent-commits-history-analysis
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // 引入Python语言支持模块
import external.VCS // 引入外部版本控制系统的集成模块

// 查询近期代码提交记录
from Commit recentCommit
// 应用过滤条件：时间范围和提交类型
where 
  recentCommit.daysToNow() <= 180 and
  not artificialChange(recentCommit)
// 输出提交的修订标识和计数
select recentCommit.getRevisionName(), 1