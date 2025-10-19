/**
 * @name 模块间共同提交文件关联分析
 * @description 量化分析特定模块文件被修改时，平均有多少其他文件会被同时提交修改
 *              这种共同提交模式揭示了模块间的耦合度和代码变更的关联性
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// 分析目标：识别模块间的共同提交模式，评估代码变更的关联性
from Module targetModule
// 筛选条件：仅考虑包含可度量代码行的模块，确保分析有意义
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  // 计算指标：当目标模块文件被修改时，平均共同修改的文件数量
  avg(Commit commit, int coCommitCount |
    // 前提条件：提交记录中包含目标模块的文件
    commit.getAnAffectedFile() = targetModule.getFile() and 
    // 计算逻辑：统计该提交中除目标文件外，其他被修改文件的数量
    coCommitCount = count(commit.getAnAffectedFile()) - 1
  |
    coCommitCount  // 返回共同修改的文件数量作为聚合计算的输入值
  )