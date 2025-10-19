/**
 * @name 近期代码提交统计
 * @description 统计最近半年内（180天）由开发人员主动提交的代码变更次数
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // 引入Python语言支持模块
import external.VCS // 引入外部版本控制系统的集成模块

// 定义变量表示一个代码提交记录
from Commit codeCommit
// 筛选时间条件：仅考虑最近180天内的提交
where codeCommit.daysToNow() <= 180
// 附加过滤条件：排除自动化或非人工生成的代码变更
and not artificialChange(codeCommit)
// 输出结果：提交的唯一修订标识符及计数值1（用于后续聚合统计）
select codeCommit.getRevisionName(), 1