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

// 查询定义：从版本控制系统中获取符合条件的提交记录
from Commit codeChange
where 
  // 时间范围筛选条件：仅包含最近半年内的提交
  codeChange.daysToNow() <= 180
  and 
  // 质量过滤条件：排除自动生成或人工干预的提交记录
  not artificialChange(codeChange)
// 结果输出：返回每个提交的修订标识符，并计为1个单位
select codeChange.getRevisionName(), 1