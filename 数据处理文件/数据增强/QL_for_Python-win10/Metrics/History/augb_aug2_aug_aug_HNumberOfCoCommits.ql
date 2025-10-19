/**
 * @name Concurrent File Modifications Analysis
 * @description Calculates the average number of additional files modified in commits 
 *              that include changes to a specific file. This metric identifies files 
 *              that are frequently modified together, indicating potential 
 *              architectural connections or code dependencies.
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Helper function that calculates the total number of files modified in a specific commit
int determineFilesModifiedInCommit(Commit commitRecord) { 
    result = count(commitRecord.getAnAffectedFile()) 
}

// Main analysis: process modules with available line count metrics
from Module targetModule
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  // Calculate the average quantity of co-modified files per module
  avg(Commit commitRecord, int concurrentChangesCount |
    // Identify commits affecting the module's file and compute co-change metrics
    commitRecord.getAnAffectedFile() = targetModule.getFile() and 
    concurrentChangesCount = determineFilesModifiedInCommit(commitRecord) - 1
  |
    concurrentChangesCount
  )