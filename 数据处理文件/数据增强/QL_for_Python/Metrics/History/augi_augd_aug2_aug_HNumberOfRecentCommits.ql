/**
 * @name 近期变更统计
 * @description 分析过去180天内的代码提交活动，以识别最近的代码变更频率
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // Python语言分析支持库
import external.VCS // 版本控制系统外部集成模块

// 查询定义：从版本控制系统中筛选出符合时间范围和质量标准的提交记录
from Commit codeCommit
where 
  // 时间范围约束：筛选出最近180天内的提交活动
  codeCommit.daysToNow() <= 180
  and 
  // 提交质量过滤：确保只统计真实的代码变更，排除自动生成或人为干预的提交
  not artificialChange(codeCommit)
// 结果输出：返回每个有效提交的修订标识符，并计为1个单位用于统计
select codeCommit.getRevisionName(), 1