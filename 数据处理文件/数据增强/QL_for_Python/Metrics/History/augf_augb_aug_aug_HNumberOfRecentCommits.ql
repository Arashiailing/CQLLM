/**
 * @name 近期代码提交活动分析
 * @description 统计最近半年内的有效代码提交频率，排除自动生成的更改
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // Python语言分析支持
import external.VCS // 版本控制系统集成模块

// 查询最近180天内的有效代码提交
from Commit commitActivity
where 
  // 时间范围限制：最近半年内
  commitActivity.daysToNow() <= 180 and
  // 排除自动生成的更改
  not artificialChange(commitActivity)
select 
  // 返回修订标识和计数
  commitActivity.getRevisionName(), 1