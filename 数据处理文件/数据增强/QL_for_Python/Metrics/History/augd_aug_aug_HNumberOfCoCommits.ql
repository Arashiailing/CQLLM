/**
 * @name Co-committed Files Count
 * @description This query determines the average quantity of extra files that are 
 *              modified alongside a particular file in the same commits. The metric 
 *              serves to identify files that often undergo changes together, which 
 *              suggests possible code coupling or interdependencies.
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Main analysis: examine modules that have line count metrics available
from Module analyzedModule
where exists(analyzedModule.getMetrics().getNumberOfLinesOfCode())
select analyzedModule,
  // Compute the mean number of files that are co-committed with each module
  avg(Commit commit, int relatedFilesCount |
    // Consider commits that modify the module's file and calculate the count of related files
    commit.getAnAffectedFile() = analyzedModule.getFile() and 
    relatedFilesCount = count(commit.getAnAffectedFile()) - 1
  |
    relatedFilesCount
  )