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

// 查询提交记录数据
from Commit commitRecord
// 应用筛选条件
where 
  // 排除人工变更
  not artificialChange(commitRecord)
  // 限制时间范围为最近180天
  and commitRecord.daysToNow() <= 180
// 返回修订名称及计数（用于聚合统计）
select commitRecord.getRevisionName(), 1