/**
 * @name 近期变更统计
 * @description 统计过去180天内的代码提交数量
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // 导入Python支持库
import external.VCS // 导入外部版本控制系统(VCS)集成库

// 从Commit类中选择数据
from Commit recentCommit
// 过滤条件：提交日期在180天以内
where recentCommit.daysToNow() <= 180
// 排除人工更改的提交
and not artificialChange(recentCommit)
// 选择提交的修订名称和计数1
select recentCommit.getRevisionName(), 1