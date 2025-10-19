/**
 * @name 近期代码提交统计
 * @description 统计分析过去180天内由开发人员主动提交的代码变更数量
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // 引入Python语言支持模块
import external.VCS // 引入外部版本控制系统的集成模块

// 定义变量表示一个近期代码提交记录
from Commit recentCommit
// 设置时间范围筛选条件：仅考虑过去半年内的提交活动
where recentCommit.daysToNow() <= 180
// 附加过滤条件：确保统计的是真实的人工提交，排除自动生成的变更
and not artificialChange(recentCommit)
// 输出结果：提交的唯一修订标识符及计数值（用于聚合统计）
select recentCommit.getRevisionName(), 1