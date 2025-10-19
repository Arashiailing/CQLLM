/**
 * @name 近期变更
 * @description 近期提交的数量
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // 导入python库
import external.VCS // 导入外部版本控制系统(VCS)库

// 从Commit类中选择数据
from Commit c
// 过滤条件：提交日期在180天以内且不是人工更改的提交
where c.daysToNow() <= 180 and not artificialChange(c)
// 选择提交的修订名称和计数1
select c.getRevisionName(), 1
