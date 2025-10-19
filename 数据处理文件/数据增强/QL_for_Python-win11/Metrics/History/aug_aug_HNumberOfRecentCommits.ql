/**
 * @name 近期代码提交统计
 * @description 计算在过去180天内发生的代码提交次数
 * @kind treemap
 * @id py/historical-number-of-recent-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

import python // 引入Python语言支持模块
import external.VCS // 引入外部版本控制系统的集成模块

// 定义变量表示一个代码提交
from Commit commitRecord
// 设置过滤条件：提交时间距离现在不超过180天
where commitRecord.daysToNow() <= 180
// 附加条件：排除非人工更改的提交记录
and not artificialChange(commitRecord)
// 输出提交的修订标识和计数1
select commitRecord.getRevisionName(), 1