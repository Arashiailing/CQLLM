/**
 * @name 代码库近期提交活动分析
 * @description 评估过去六个月（180天）内代码库的开发活跃度，
 *              通过筛选有效的开发提交，排除系统自动生成的变更，
 *              为项目进展提供量化指标。
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // Python语言分析支持模块
import external.VCS // 版本控制系统分析模块

// 查询源：获取所有代码提交记录
from Commit codeCommit
// 筛选条件：确保是有效的开发提交且在指定时间范围内
where 
  // 排除系统自动生成或非人工操作的变更
  not artificialChange(codeCommit)
  and
  // 限定时间范围为最近180天内的提交
  codeCommit.daysToNow() <= 180
// 输出格式：返回提交修订标识符和计数值（用于聚合统计）
select codeCommit.getRevisionName(), 1