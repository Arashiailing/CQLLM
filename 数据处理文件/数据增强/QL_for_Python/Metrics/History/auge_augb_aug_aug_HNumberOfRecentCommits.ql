/**
 * @name 代码提交活跃度分析
 * @description 分析并统计过去六个月内的人工代码提交活动频率
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // Python语言分析支持
import external.VCS // 版本控制系统集成模块

// 筛选条件：时间范围在最近180天内的非自动生成提交
from Commit commitWithinSixMonths
where 
  // 提交时间在最近半年内
  commitWithinSixMonths.daysToNow() <= 180  
  and 
  // 排除由系统或工具自动生成的更改
  not artificialChange(commitWithinSixMonths)  
select commitWithinSixMonths.getRevisionName(), 1  // 输出提交修订标识及其计数（用于统计）