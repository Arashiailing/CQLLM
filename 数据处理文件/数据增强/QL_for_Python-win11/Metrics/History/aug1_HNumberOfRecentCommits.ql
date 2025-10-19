/**
 * @name 近期代码提交分析
 * @description 统计最近180天内的代码提交数量，排除人工变更
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // 导入Python语言分析库
import external.VCS // 导入版本控制系统(VCS)外部库

// 查询提交记录数据
from Commit commitEntry
// 应用筛选条件：1. 提交时间在180天内；2. 非人工变更
where 
  commitEntry.daysToNow() <= 180 and 
  not artificialChange(commitEntry)
// 返回修订名称及计数（用于聚合统计）
select commitEntry.getRevisionName(), 1