/**
 * @name 代码提交历史活动评估
 * @description 分析并计算过去六个月内有效代码提交的分布情况
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // Python语言分析支持
import external.VCS // 版本控制系统集成模块

// 获取符合条件的代码提交记录
from Commit recentCommit
where 
  // 限制时间范围：只分析最近半年（180天）内的提交活动
  recentCommit.daysToNow() <= 180
  and 
  // 过滤质量：排除自动化工具生成的变更
  not artificialChange(recentCommit)
select recentCommit.getRevisionName(), 1  // 返回修订版本标识符及其计数