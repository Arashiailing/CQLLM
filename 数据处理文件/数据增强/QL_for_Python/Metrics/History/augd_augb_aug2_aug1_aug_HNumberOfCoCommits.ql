/**
 * @name 共同提交文件数量分析
 * @description 当特定模块中的文件被修改时，计算平均有多少其他文件被同时修改（共同提交）
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// 主分析逻辑：评估不同模块间的文件共同修改模式
from Module targetModule
// 筛选条件：仅处理具有可度量代码行的模块
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  // 计算当目标模块文件被修改时，平均共同修改的文件数量
  avg(Commit commit, int coChangedCount |
    // 条件1：提交记录包含目标模块中的文件
    commit.getAnAffectedFile() = targetModule.getFile() and 
    // 条件2：计算该提交中其他被修改文件的数量
    coChangedCount = count(commit.getAnAffectedFile()) - 1
  |
    coChangedCount  // 返回共同修改的文件数量
  )