/**
 * @name Number of co-committed files
 * @description The average number of other files that are touched whenever a file is affected by a commit
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// 定义一个函数，用于计算某个提交中受影响的文件数量
int committedFiles(Commit commit) { result = count(commit.getAnAffectedFile()) }

// 从模块m中选择数据
from Module m
// 过滤条件：模块m存在行数度量指标
where exists(m.getMetrics().getNumberOfLinesOfCode())
select m,
  // 计算并选择每个模块的平均值
  avg(Commit commit, int toAvg |
    // 条件：提交中的受影响文件等于模块中的文件，并且计算toAvg值
    commit.getAnAffectedFile() = m.getFile() and toAvg = committedFiles(commit) - 1
  |
    toAvg
  )
