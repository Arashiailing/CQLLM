/**
 * @name 近期代码提交活动分析
 * @description 评估过去180天内有效代码提交的频率分布，过滤掉自动化或人为干预的提交记录
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // Python语言分析支持库
import external.VCS // 版本控制系统外部集成模块

// 主查询：识别并统计符合特定条件的代码提交记录
from Commit validCommit
where 
  // 时间范围约束：仅分析最近半年内的提交活动
  validCommit.daysToNow() <= 180
  and
  // 提交质量过滤：排除非人工编写的代码变更
  not artificialChange(validCommit)

// 输出结果：以提交修订ID为标识，每条有效提交计为1个单位
select validCommit.getRevisionName(), 1