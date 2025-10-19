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

// Filter modules that have valid metrics for co-modification analysis
from Module analyzedModule
where exists(analyzedModule.getMetrics().getNumberOfLinesOfCode())
select analyzedModule,
  // Compute the average number of files co-modified with this module's files
  avg(Commit versionCommit, int coModifiedFilesCount |
    // Identify commits that affect the target module's file
    versionCommit.getAnAffectedFile() = analyzedModule.getFile() and 
    // Calculate the count of additional files modified in the same commit (excluding the module file)
    coModifiedFilesCount = count(versionCommit.getAnAffectedFile()) - 1
  |
    coModifiedFilesCount
  )