/**
 * @name 代码提交活跃度分析
 * @description 检测并计算过去半年内有效代码提交的分布情况，过滤掉系统生成或人为干预的提交记录
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // Python语言分析支持库
import external.VCS // 版本控制系统外部集成模块

// 时间范围定义：设定为最近180天（约半年）的提交活动
// 提交有效性验证：确保统计的提交是真实的开发活动，而非自动生成或人工干预的结果
from Commit validCommit
where 
  // 应用时间筛选条件：只统计在指定时间范围内的提交
  validCommit.daysToNow() <= 180 and
  // 应用完整性验证：排除非人为或非真实的代码变更
  not artificialChange(validCommit)

// 输出格式：每个有效提交以其修订标识符作为唯一标识，计数为1
select validCommit.getRevisionName(), 1