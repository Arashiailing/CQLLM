/**
 * @name Co-committed Files Analysis
 * @description Calculates the average number of additional files modified in commits 
 *              that also change a specific file. This metric identifies files that 
 *              are frequently altered together, indicating potential relationships 
 *              or dependencies between them.
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Helper function that calculates the number of files modified in a specific commit
int calculateFilesModifiedInCommit(Commit commitRecord) { 
    result = count(commitRecord.getAnAffectedFile()) 
}

// Main analysis: evaluate modules with line count metrics
from Module targetModule
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  // Compute the average number of files modified together with the target module
  avg(Commit commitRecord, int coModifiedFilesCount |
    // Check if the commit affects the target module
    commitRecord.getAnAffectedFile() = targetModule.getFile() and 
    // Calculate the number of co-modified files (excluding the target module)
    coModifiedFilesCount = calculateFilesModifiedInCommit(commitRecord) - 1
  |
    coModifiedFilesCount
  )