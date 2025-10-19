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

// Helper function: Determines the total count of files modified in a specific commit
int calculateTotalFilesInCommit(Commit modification) { 
    result = count(modification.getAnAffectedFile()) 
}

// Main analysis: Examines co-modification patterns across different modules
from Module analyzedModule
// Restriction: Focus only on modules that have lines of code metrics available
where exists(analyzedModule.getMetrics().getNumberOfLinesOfCode())
select analyzedModule,
  // Compute the average count of co-committed files for the module
  avg(Commit relevantCommit, int associatedFileCount |
    // Criteria: The commit must affect a file from the current module
    relevantCommit.getAnAffectedFile() = analyzedModule.getFile() and 
    // Calculate other files modified in the same commit
    associatedFileCount = calculateTotalFilesInCommit(relevantCommit) - 1
  |
    associatedFileCount
  )