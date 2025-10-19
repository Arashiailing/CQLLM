/**
 * @name 模块间共同提交文件关联分析
 * @description 评估当特定模块中的文件被修改时，平均有多少其他文件被同时提交修改（共同提交现象）
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// 核心分析逻辑：评估不同模块间的文件共同修改模式
from Module analyzedModule
// 过滤条件：仅处理具有可度量代码行的模块
where exists(analyzedModule.getMetrics().getNumberOfLinesOfCode())
select analyzedModule,
  // 计算当目标模块文件被修改时，平均共同修改的文件数量
  avg(Commit revision, int jointlyModifiedCount |
    // 条件1：提交记录包含目标模块中的文件
    revision.getAnAffectedFile() = analyzedModule.getFile() and 
    // 条件2：计算该提交中其他被修改文件的数量
    jointlyModifiedCount = count(revision.getAnAffectedFile()) - 1
  |
    jointlyModifiedCount  // 返回共同修改的文件数量
  )