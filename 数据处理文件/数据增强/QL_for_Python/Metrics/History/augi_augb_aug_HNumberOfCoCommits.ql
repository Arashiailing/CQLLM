/**
 * @name Number of co-committed files
 * @description Analyzes the average number of additional files modified alongside a given file in each commit
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Main analysis: Computes average co-committed files per module
from Module targetModule
// Restriction: Only process modules with available code metrics
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  // Calculate average co-committed files across all relevant commits
  avg(Commit commit, int coCommitCount |
    // Condition: Commit must affect a file from the target module
    commit.getAnAffectedFile() = targetModule.getFile() and 
    // Compute additional files modified in the same commit
    coCommitCount = count(commit.getAnAffectedFile()) - 1
  |
    coCommitCount
  )