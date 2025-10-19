/**
 * @name 代码提交活跃度分析
 * @description 分析过去180天内的代码提交活动，排除自动化或人工干预的变更
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // 导入Python语言分析库，用于Python代码分析
import external.VCS // 导入版本控制系统(VCS)外部库，提供提交历史访问功能

// 查询符合条件的历史提交记录
from Commit commitRecord
where 
  // 时间范围筛选：仅考虑最近180天内的提交
  commitRecord.daysToNow() <= 180 and 
  // 内容筛选：排除人工或自动化变更，专注于实际代码更改
  not artificialChange(commitRecord)
// 输出格式：修订名称作为分组依据，数值1用于后续聚合计算
select commitRecord.getRevisionName(), 1