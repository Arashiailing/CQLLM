/**
 * @name Co-committed Files Analysis
 * @description Analyzes the average number of additional files modified in commits 
 *              that also change a specific file. This metric identifies files 
 *              frequently altered together, indicating potential relationships 
 *              or dependencies between them.
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Helper function that calculates the total number of files modified in a specific commit
int countFilesModifiedInCommit(Commit commitRecord) { 
    result = count(commitRecord.getAnAffectedFile()) 
}

// Main analysis: process modules with available line count metrics
from Module targetModule
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  // Calculate the average number of co-modified files for each target module
  avg(Commit relevantCommit, int coModifiedFilesCount |
    // Find commits that affect the target module's file and compute co-change count
    relevantCommit.getAnAffectedFile() = targetModule.getFile() and 
    coModifiedFilesCount = countFilesModifiedInCommit(relevantCommit) - 1
  |
    coModifiedFilesCount
  )