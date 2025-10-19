/**
 * @name 代码提交频率分析
 * @description 评估过去180天内的代码提交活动，计算提交总数
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // Python语言分析支持库
import external.VCS // 版本控制系统外部集成模块

// 查询定义：从版本控制系统中提取提交数据
from Commit commitEntry
// 时间范围筛选：仅包含最近半年内的提交
where commitEntry.daysToNow() <= 180
// 质量过滤：排除自动生成或人工干预的提交记录
and not artificialChange(commitEntry)
// 结果输出：返回每个提交的修订标识符，并计为1个单位
select commitEntry.getRevisionName(), 1