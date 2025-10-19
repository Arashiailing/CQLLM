/**
 * @name 代码提交历史统计
 * @description 统计最近半年内的代码提交活动数量
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // Python语言分析支持库
import external.VCS // 版本控制系统外部集成模块

// 定义查询范围：从版本控制系统中获取符合时间条件的提交记录
from Commit recentCommit
// 时间约束：仅统计180天内的提交活动
where recentCommit.daysToNow() <= 180
// 数据质量过滤：排除非人工编写的代码变更（如自动生成或系统干预）
and not artificialChange(recentCommit)
// 输出格式：每条提交记录以其修订标识符表示，并计数为1
select recentCommit.getRevisionName(), 1