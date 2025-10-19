/**
 * @name 代码库活跃度评估
 * @description 分析过去半年（180天）内的代码提交活动，以量化评估代码库的开发活跃状态
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // 引入Python语言支持模块
import external.VCS // 引入外部版本控制系统的集成模块

// 声明变量表示代码库中的提交记录
from Commit commitRecord
// 应用过滤条件以筛选符合条件的提交
where 
  // 筛选条件1：提交发生在最近180天的时间窗口内
  commitRecord.daysToNow() <= 180
  // 筛选条件2：排除系统自动生成的非人工提交记录
  and not artificialChange(commitRecord)
// 输出提交的唯一修订标识符和计数值1（用于统计总数）
select commitRecord.getRevisionName(), 1