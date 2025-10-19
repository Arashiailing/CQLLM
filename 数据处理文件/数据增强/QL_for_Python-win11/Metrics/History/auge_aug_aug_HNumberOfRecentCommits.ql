/**
 * @name 代码提交活跃度分析
 * @description 统计最近180天内的代码提交活动频率，用于评估代码库的活跃程度
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // 引入Python语言支持模块
import external.VCS // 引入外部版本控制系统的集成模块

// 定义变量表示一个代码提交记录
from Commit recentCommit
// 设置双重过滤条件：时间范围和提交类型
where 
  // 条件1：提交发生在最近180天内
  recentCommit.daysToNow() <= 180 and
  // 条件2：排除自动生成的非人工更改
  not artificialChange(recentCommit)
// 输出提交的修订标识符以及用于计数的数值1
select recentCommit.getRevisionName(), 1