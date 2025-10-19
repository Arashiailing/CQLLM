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

// 定义数据源：从版本控制系统中获取提交记录
from Commit recentCommit

// 应用筛选条件
where 
  // 筛选条件1：提交时间在最近180天内
  recentCommit.daysToNow() <= 180 
  // 筛选条件2：排除人工变更的提交
  and not artificialChange(recentCommit)

// 生成结果：返回修订名称及计数（用于聚合统计）
select recentCommit.getRevisionName(), 1