/**
 * @name 代码库近期提交活动分析
 * @description 量化分析过去半年内代码库的提交频率和活跃度
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // Python语言分析支持库
import external.VCS // 版本控制系统外部集成模块

// 查询定义：从版本控制系统中获取提交记录
from Commit codeCommit
where
  // 时间范围约束：筛选位于最近半年时间窗口内的提交
  codeCommit.daysToNow() <= 180 and
  // 数据完整性过滤：排除自动生成或人工干预的提交
  not artificialChange(codeCommit)
// 结果输出：提交修订标识符作为唯一标识，每个提交计为一个单位
select codeCommit.getRevisionName(), 1