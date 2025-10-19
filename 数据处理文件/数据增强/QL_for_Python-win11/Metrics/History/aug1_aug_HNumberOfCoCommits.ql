/**
 * @name Number of co-committed files
 * @description Measures the average number of files that are modified together whenever a specific file is changed in a commit
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Helper function: Computes the total count of files modified in a given commit
int getFilesModifiedInCommit(Commit commit) { 
    result = count(commit.getAnAffectedFile()) 
}

// Main analysis: Examines co-modification patterns across different modules
from Module analyzedModule
// Restriction: Focus only on modules that have lines of code metrics available
where exists(analyzedModule.getMetrics().getNumberOfLinesOfCode())
select analyzedModule,
  // Compute the average number of files co-modified with files in this module
  avg(Commit commitImpact, int coChangedFilesCount |
    // Define condition for commit affecting the module
    commitImpact.getAnAffectedFile() = analyzedModule.getFile() and 
    // Calculate the count of other files modified in the same commit
    coChangedFilesCount = getFilesModifiedInCommit(commitImpact) - 1
  |
    coChangedFilesCount
  )