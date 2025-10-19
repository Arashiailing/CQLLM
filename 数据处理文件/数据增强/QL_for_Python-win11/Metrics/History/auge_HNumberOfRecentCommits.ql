/**
 * @name 代码提交频率分析
 * @description 统计最近半年内的代码提交活动
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // 导入python库
import external.VCS // 导入外部版本控制系统(VCS)库

// 从Commit类中选择数据
from Commit commitRecord
// 过滤条件：提交日期在180天以内且不是人工更改的提交
where 
  // 只考虑最近180天内的提交
  commitRecord.daysToNow() <= 180 and
  // 排除人工生成的更改
  not artificialChange(commitRecord)
// 选择提交的修订名称和计数1
select 
  // 获取提交的修订名称
  commitRecord.getRevisionName(), 
  // 每个提交计数为1
  1