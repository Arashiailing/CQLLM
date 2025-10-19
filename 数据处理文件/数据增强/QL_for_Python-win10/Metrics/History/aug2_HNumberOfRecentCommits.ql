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

// 定义时间阈值：180天
int timeThreshold() { result = 180 }

// 从提交历史中选择数据
from Commit recentCommit
// 应用过滤条件：提交时间在阈值范围内且非人工变更
where 
  recentCommit.daysToNow() <= timeThreshold() and 
  not artificialChange(recentCommit)
// 输出修订名称和计数（用于聚合统计）
select recentCommit.getRevisionName(), 1