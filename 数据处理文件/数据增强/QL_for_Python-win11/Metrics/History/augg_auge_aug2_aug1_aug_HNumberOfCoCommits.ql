/**
 * @name Co-committed Files Analysis
 * @description Quantifies the average number of files that are modified together with a module's files
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Identify modules with valid metrics for co-modification analysis
from Module targetModule
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  // Calculate the average number of files modified together with this module
  avg(Commit commit, int coChangedFilesCount |
    // Find commits that modify files in the target module
    commit.getAnAffectedFile() = targetModule.getFile() and 
    // Compute additional files modified in the same commit (excluding the module file)
    coChangedFilesCount = count(commit.getAnAffectedFile()) - 1
  |
    coChangedFilesCount
  )