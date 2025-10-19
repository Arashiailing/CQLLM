/**
 * @name 代码库活跃度分析
 * @description 评估过去六个月（180天）内的代码提交频率，用于衡量代码库的开发活跃程度
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // 导入Python语言支持模块
import external.VCS // 导入外部版本控制系统接口

// 查询最近半年内的人工提交记录
from Commit recentCommit
where 
  // 确保提交发生在最近180天内
  recentCommit.daysToNow() <= 180
  // 并且不是系统自动生成的提交
  and not artificialChange(recentCommit)
// 返回提交的修订标识符和计数（用于聚合统计）
select recentCommit.getRevisionName(), 1