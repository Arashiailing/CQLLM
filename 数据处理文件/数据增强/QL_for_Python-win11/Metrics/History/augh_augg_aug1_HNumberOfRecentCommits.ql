/**
 * @name 近期代码提交分析
 * @description 计算最近六个月内有效代码提交的总量，排除自动生成的变更
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // Python语言分析模块
import external.VCS // 外部版本控制支持模块

// 从版本控制系统中提取所有提交记录
from Commit commitRecord
// 应用过滤条件，筛选出符合条件的有效提交
where 
  // 时间过滤：仅包含最近180天内的提交
  commitRecord.daysToNow() <= 180 and 
  // 内容过滤：排除自动生成的变更（如CI/CD工具生成的提交）
  not artificialChange(commitRecord)
// 输出结果：返回修订名称作为分组依据，值1用于后续聚合计算
select commitRecord.getRevisionName(), 1