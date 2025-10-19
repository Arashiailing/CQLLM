/**
 * @name 近期变更分析
 * @description 统计过去180天内的非人工提交数量
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python
import external.VCS

// 定义查询主体：从版本控制系统提交记录中选择数据
from Commit commitRecord
// 应用过滤条件：仅包含近期提交且排除人工更改
where 
  // 提交日期在180天以内
  commitRecord.daysToNow() <= 180
  and 
  // 排除人工更改的提交记录
  not artificialChange(commitRecord)
// 输出结果：提交修订名称和计数（用于聚合）
select commitRecord.getRevisionName(), 1