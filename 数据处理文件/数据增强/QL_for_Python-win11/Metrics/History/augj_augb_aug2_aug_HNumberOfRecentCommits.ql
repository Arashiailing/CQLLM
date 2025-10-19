/**
 * @name 代码提交活动频率分析
 * @description 量化分析最近180天内的代码提交活动，用于评估开发活跃度
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // Python语言分析支持库
import external.VCS // 版本控制系统外部集成模块

// 查询定义：从版本控制历史中提取符合条件的代码提交记录
from Commit codeCommit
// 时间范围筛选：限定统计范围为最近半年内的提交活动
where codeCommit.daysToNow() <= 180
// 数据质量过滤：排除系统自动生成或人工干预的提交记录，确保统计结果真实反映开发活动
and not artificialChange(codeCommit)
// 结果输出：以提交修订标识符作为唯一键，每条有效提交记录计为一个统计单位
select codeCommit.getRevisionName(), 1