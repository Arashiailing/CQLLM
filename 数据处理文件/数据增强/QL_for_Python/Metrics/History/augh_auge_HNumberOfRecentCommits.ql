/**
 * @name 代码提交频率分析
 * @description 分析最近半年内的代码提交活动，评估项目开发活跃度
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // 导入Python语言支持库
import external.VCS // 导入版本控制系统(VCS)集成库

// 从Commit类中选择符合条件的提交记录
from Commit recentCommit
where 
  // 条件1：筛选最近180天内的提交（约半年时间范围）
  recentCommit.daysToNow() <= 180
  and
  // 条件2：排除由自动化工具生成的非人工提交
  not artificialChange(recentCommit)
// 输出提交的唯一修订标识符及计数
select 
  // 获取提交的修订名称作为标识
  recentCommit.getRevisionName(), 
  // 每个提交记录计为1个单位，用于统计汇总
  1