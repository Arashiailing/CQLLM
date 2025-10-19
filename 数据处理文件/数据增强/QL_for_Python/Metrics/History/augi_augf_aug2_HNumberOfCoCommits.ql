/**
 * @name Co-committed files analysis
 * @description Calculates the average number of files that are modified together with each file
 *              across all commits that modify that particular file
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Primary analysis for co-committed file patterns
from Module analyzedModule
where exists(analyzedModule.getMetrics().getNumberOfLinesOfCode())
select analyzedModule,
  // Compute the average count of files modified alongside this module
  avg(int coChangedFilesCount |
    // Find commits affecting this module's file
    exists(Commit versionCommit |
      versionCommit.getAnAffectedFile() = analyzedModule.getFile() and
      // Calculate co-committed files (total affected files minus the module itself)
      coChangedFilesCount = count(versionCommit.getAnAffectedFile()) - 1
    )
  |
    coChangedFilesCount
  )