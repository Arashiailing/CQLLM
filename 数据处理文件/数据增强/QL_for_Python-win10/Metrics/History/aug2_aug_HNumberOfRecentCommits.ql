/**
 * @name 近期变更统计
 * @description 统计过去180天内的代码提交数量
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // Python语言分析支持库
import external.VCS // 版本控制系统外部集成模块

// 查询定义：从版本控制系统中获取提交记录
from Commit commitInRange
// 时间范围筛选：仅包含最近半年内的提交
where commitInRange.daysToNow() <= 180
// 质量过滤：排除自动生成或人工干预的提交记录
and not artificialChange(commitInRange)
// 结果输出：返回每个提交的修订标识符，并计为1个单位
select commitInRange.getRevisionName(), 1