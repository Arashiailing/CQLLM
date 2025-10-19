/**
 * @name 近期变更分析
 * @description 统计过去180天内非人工提交的代码变更数量
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // 导入Python语言分析库
import external.VCS // 导入外部版本控制系统(VCS)分析库

// 从提交历史中筛选符合条件的记录
from Commit commitRecord
// 应用过滤条件：排除人工变更且时间在阈值内
where 
  not artificialChange(commitRecord) and 
  commitRecord.daysToNow() <= 180
// 输出修订名称和计数（用于聚合统计）
select commitRecord.getRevisionName(), 1