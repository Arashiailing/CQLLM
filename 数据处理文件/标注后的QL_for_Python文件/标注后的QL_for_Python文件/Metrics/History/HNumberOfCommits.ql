/**
 * @name Number of commits
 * @description Number of commits
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// 导入python库
import python
// 导入版本控制系统(VCS)相关库
import external.VCS

// 从提交记录中选择数据
from Commit c
// 过滤掉人工更改的提交记录
where not artificialChange(c)
// 选择提交的修订名称和计数1
select c.getRevisionName(), 1
