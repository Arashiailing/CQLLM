/**
 * @name 近期代码提交分析
 * @description 统计最近180天内的代码提交数量，排除人工变更。此查询用于识别代码库的活跃度，
 *              通过分析提交频率来评估项目的开发活动水平。
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // 导入Python语言分析库
import external.VCS // 导入版本控制系统(VCS)外部库

// 查询提交记录数据
from Commit recentCommit
// 应用筛选条件：1. 非人工变更；2. 提交时间在180天内
where 
  not artificialChange(recentCommit) and
  recentCommit.daysToNow() <= 180
// 返回修订名称及计数（用于聚合统计）
select recentCommit.getRevisionName(), 1