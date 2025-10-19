/**
 * @name Number of recent authors
 * @description Number of distinct authors that have recently made changes
 * @kind treemap
 * @id py/historical-number-of-recent-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python // 导入python库，用于处理Python代码
import external.VCS // 导入外部版本控制系统（VCS）库，用于访问版本控制信息

// 定义查询的数据源：Python模块
from Module moduleObj
// 筛选条件：只考虑具有代码行数统计信息的模块
where exists(moduleObj.getMetrics().getNumberOfLinesOfCode())
// 选择模块并计算最近180天内的不同代码作者数量
select moduleObj,
  count(Author codeAuthor |
    // 检查是否存在符合条件的提交记录
    exists(Commit commitRecord |
      // 提交记录必须属于当前代码作者
      commitRecord = codeAuthor.getACommit() and
      // 提交必须影响了当前模块的文件
      moduleObj.getFile() = commitRecord.getAnAffectedFile() and
      // 提交时间必须在最近180天内
      commitRecord.daysToNow() <= 180 and
      // 排除人工变更（如自动生成的提交）
      not artificialChange(commitRecord)
    )
  )