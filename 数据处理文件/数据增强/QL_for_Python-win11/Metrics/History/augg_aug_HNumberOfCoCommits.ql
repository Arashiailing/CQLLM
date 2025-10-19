/**
 * @name Number of co-committed files
 * @description Measures the average quantity of additional files modified alongside a given file in each commit
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Helper function: Computes the total number of files affected in a specific commit
int calculateFilesInCommit(Commit commit) { 
    result = count(commit.getAnAffectedFile()) 
}

// Main analysis: Evaluates co-commit behavior patterns for each module
from Module selectedModule
// Filtering condition: Only process modules that have lines of code metrics available
where exists(selectedModule.getMetrics().getNumberOfLinesOfCode())
select selectedModule,
  // Determine the average count of co-committed files for each module
  avg(Commit relatedCommit, int associatedFilesCount |
    // Requirement: Commit must affect current module's file, then calculate other files in same commit
    relatedCommit.getAnAffectedFile() = selectedModule.getFile() and 
    associatedFilesCount = calculateFilesInCommit(relatedCommit) - 1
  |
    associatedFilesCount
  )