/**
 * @name 近期代码提交分析
 * @description 计算最近六个月内有效代码提交的总量，排除自动生成的变更
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // Python语言分析模块
import external.VCS // 外部版本控制支持模块

// 获取提交记录
from Commit recentCommit
// 应用过滤条件
where 
  // 提交发生在最近180天内
  recentCommit.daysToNow() <= 180 and 
  // 排除人工变更
  not artificialChange(recentCommit)
// 返回修订名称和计数值，用于聚合统计
select recentCommit.getRevisionName(), 1