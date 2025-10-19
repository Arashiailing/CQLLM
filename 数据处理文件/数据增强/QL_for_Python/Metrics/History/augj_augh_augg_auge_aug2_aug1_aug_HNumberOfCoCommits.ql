/**
 * @name Co-committed Files Analysis
 * @description This analysis quantifies the average number of files that are modified together 
 *              with a module's files in the same commit. It helps identify modules that are 
 *              frequently modified in conjunction with other files, which may indicate tight 
 *              coupling or dependencies.
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Select modules with valid code metrics for co-modification analysis
from Module targetModule
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  // Calculate the average number of files co-modified with this module's files
  avg(Commit commit, int coChangedCount |
    // Identify commits that modify the target module's file
    targetModule.getFile() = commit.getAnAffectedFile() and 
    // Compute the number of additional files modified in the same commit
    // (excluding the module's own file)
    coChangedCount = count(commit.getAnAffectedFile()) - 1
  |
    coChangedCount
  )