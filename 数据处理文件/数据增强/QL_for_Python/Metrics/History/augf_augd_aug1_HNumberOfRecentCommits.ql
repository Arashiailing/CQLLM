/**
 * @name 代码仓库提交频率统计
 * @description 统计最近半年内的有效代码提交次数，过滤掉非开发性质的变更
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // 导入Python语言分析库，用于处理Python代码库
import external.VCS // 引入版本控制外部模块，用于访问代码提交历史数据

// 获取所有符合条件的代码提交记录
from Commit commitEntry
where 
  // 筛选时间条件：只分析最近180天内的提交活动
  commitEntry.daysToNow() <= 180 and 
  // 内容过滤条件：排除人工干预或自动生成的变更，确保只统计真实开发活动
  not artificialChange(commitEntry)
// 结果输出：使用修订名称作为分组键，数值1用于后续统计汇总
select commitEntry.getRevisionName(), 1