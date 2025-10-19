/**
 * @name 代码活跃度分析
 * @description 分析过去半年内的代码提交活动，过滤掉非开发相关的变更。该查询旨在评估代码库的活跃状态，
 *              通过统计提交频率来衡量项目的开发进展情况。
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // 导入Python语言分析库
import external.VCS // 导入版本控制系统(VCS)外部库

// 查询过去半年内的有效代码提交记录
from Commit recentCommit
where 
  // 排除自动生成或非开发相关的变更
  not artificialChange(recentCommit)
  // 筛选最近180天内的提交记录
  and recentCommit.daysToNow() <= 180
// 返回修订名称及计数（用于聚合统计活跃度）
select recentCommit.getRevisionName(), 1