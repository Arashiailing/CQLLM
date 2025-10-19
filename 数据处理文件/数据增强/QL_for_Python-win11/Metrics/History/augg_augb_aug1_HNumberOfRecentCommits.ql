/**
 * @name 近期代码提交活跃度分析
 * @description 检测过去半年内（180天）的代码提交活动，过滤掉非开发相关的系统变更。
 *              该查询用于评估代码库的开发活跃度，通过统计有效提交频率来衡量项目进展。
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // 引入Python语言分析支持库
import external.VCS // 引入版本控制系统的外部分析库

// 定义查询源：获取所有提交记录
from Commit commitRecord
// 设定筛选条件：排除非开发变更并限定时间范围
where 
  // 条件1：排除自动化或系统生成的人工变更
  not artificialChange(commitRecord) and
  // 条件2：仅统计最近180天内的提交活动
  commitRecord.daysToNow() <= 180
// 输出结果：返回修订标识符和计数值（用于后续聚合计算）
select commitRecord.getRevisionName(), 1