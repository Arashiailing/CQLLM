/**
 * @name 近期代码提交活动分析
 * @description 统计最近半年内的代码提交频率
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // Python语言分析支持
import external.VCS // 版本控制系统集成模块

// 查找在指定时间范围内且非自动生成的代码提交记录
from Commit validCommit
where 
  // 检查提交是否发生在最近180天内（半年时间窗口）
  validCommit.daysToNow() <= 180
  and
  // 确保提交不是由系统自动生成的
  not artificialChange(validCommit)
select validCommit.getRevisionName(), 1  // 返回修订标识和计数（每个提交计为1）