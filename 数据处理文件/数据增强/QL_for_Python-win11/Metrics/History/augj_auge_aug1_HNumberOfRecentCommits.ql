/**
 * @name 最新代码提交频率统计
 * @description 计算过去半年（180天）内的代码提交活动数量，过滤掉非人工生成的变更
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // 导入Python语言分析支持库
import external.VCS // 引入版本控制系统的外部接口

// 数据来源：从版本控制历史中提取提交记录
from Commit commitRecord

// 应用过滤规则
where 
  // 规则1：只考虑最近180天内的提交活动
  commitRecord.daysToNow() <= 180 
  // 规则2：排除系统自动生成的变更记录
  and not artificialChange(commitRecord)

// 输出结果：提供修订标识符和计数值（用于后续聚合计算）
select commitRecord.getRevisionName(), 1