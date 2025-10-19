/**
 * @name 近期代码提交统计
 * @description 统计最近半年内非自动生成的代码提交次数
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // Python语言分析模块
import external.VCS // 外部版本控制支持模块

// 查询符合条件的提交记录
from Commit currentCommit
where 
  // 时间条件：提交发生在最近180天内
  currentCommit.daysToNow() <= 180 and 
  // 内容条件：排除自动生成的变更
  not artificialChange(currentCommit)
// 输出结果：修订名称和计数值，用于聚合统计
select currentCommit.getRevisionName(), 1