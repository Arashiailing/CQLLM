/**
 * @name Number of co-committed files
 * @description Measures the average number of files modified together with files in a module
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Identify modules with valid metrics for analysis
from Module targetModule
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  // Calculate the average number of files co-committed with the target module
  avg(Commit revision, int coCommittedFileCount |
    // Find commits that affect the target module
    revision.getAnAffectedFile() = targetModule.getFile() and 
    // Count the total files modified in the commit, excluding the target module file
    coCommittedFileCount = count(revision.getAnAffectedFile()) - 1
  |
    coCommittedFileCount
  )