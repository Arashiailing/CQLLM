/**
 * @name 近期代码提交活动分析
 * @description 统计并分析过去180天内的代码提交活动频率
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // Python语言分析支持库
import external.VCS // 版本控制系统外部集成模块

// 查询定义：从版本控制系统中筛选有效提交记录
from Commit recentCommit
// 时间条件：筛选位于最近半年时间窗口内的提交
where recentCommit.daysToNow() <= 180
// 完整性过滤：排除自动生成或人工干预的提交，确保统计准确性
and not artificialChange(recentCommit)
// 结果输出：提交修订标识符作为唯一标识，每个提交计为一个单位
select recentCommit.getRevisionName(), 1