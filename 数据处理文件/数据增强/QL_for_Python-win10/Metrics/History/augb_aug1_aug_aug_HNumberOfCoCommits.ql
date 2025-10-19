/**
 * @name Co-committed Files Count
 * @description Calculates the average number of additional files modified in commits 
 *              that include changes to a specific file. This metric helps identify 
 *              files that are frequently altered together, indicating potential 
 *              code coupling or hidden dependencies.
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Primary analysis: examine modules with measurable code metrics
from Module targetModule
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  // Calculate the average number of co-committed files for each target module
  avg(Commit relevantCommit, int coCommitCount |
    // Identify commits affecting the target module's file
    relevantCommit.getAnAffectedFile() = targetModule.getFile() and 
    // Compute co-commit count (total files in commit minus the target file)
    coCommitCount = count(relevantCommit.getAnAffectedFile()) - 1
  |
    coCommitCount
  )