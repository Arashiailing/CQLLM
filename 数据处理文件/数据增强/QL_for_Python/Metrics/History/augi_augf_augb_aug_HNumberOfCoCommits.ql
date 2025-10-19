/**
 * @name Co-committed Files Analysis
 * @description Measures the average number of files modified together with a specific file in each commit
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Helper function: Determines the total count of files modified in a commit
int countFilesInCommit(Commit commitObj) { 
    result = count(commitObj.getAnAffectedFile()) 
}

// Main analysis: Calculates the average number of files co-modified with each Python module
from Module targetModule
// Precondition: Ensure the module has lines-of-code information available
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  // Calculate the average number of files modified alongside this module
  avg(Commit commitObj, int coChangedFileCount |
    // Constraint: The commit must include a file from the current module
    commitObj.getAnAffectedFile() = targetModule.getFile() and 
    // Compute the count of other files modified in the same commit
    coChangedFileCount = countFilesInCommit(commitObj) - 1
  |
    coChangedFileCount
  )