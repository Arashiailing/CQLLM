/**
 * @name 近期代码提交分析
 * @description 检测并计算过去半年内由真实开发者直接提交的代码变更数量
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python
import external.VCS

// 查询目标：识别所有符合特定条件的代码提交记录
from Commit currentCommit
// 筛选条件：时间限制与提交来源过滤
where 
  // 时间筛选：只关注最近180天（约半年）内的提交活动
  currentCommit.daysToNow() <= 180
  and 
  // 来源筛选：排除由自动化系统或工具生成的提交，保留人工直接提交的代码变更
  not artificialChange(currentCommit)
// 结果输出：提取每条有效提交的唯一修订标识符，并分配计数单位1以便后续统计分析
select currentCommit.getRevisionName(), 1