/**
 * @name 代码库近期提交活动分析
 * @description 分析最近180天内的代码提交活动，排除自动生成的变更。此查询用于评估代码库的活跃度，
 *              通过统计提交频率来衡量项目的开发活动水平。
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // Python语言分析支持库
import external.VCS // 版本控制系统(VCS)外部分析库

// 从版本控制系统中获取提交记录
from Commit commitRecord
where 
  // 排除自动生成的变更（如格式化、重构工具生成的提交）
  not artificialChange(commitRecord)
  and
  // 时间范围限制：仅统计最近半年内的提交
  commitRecord.daysToNow() <= 180
// 输出结果：修订名称和计数（用于后续聚合统计）
select commitRecord.getRevisionName(), 1