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

// 筛选符合条件的代码提交记录
from Commit commitRecord
where 
  // 时间限制：仅考虑最近180天内的提交活动
  commitRecord.daysToNow() <= 180
  and 
  // 质量过滤：排除由系统自动生成的变更
  not artificialChange(commitRecord)
select commitRecord.getRevisionName(), 1  // 输出修订版本标识符和提交计数