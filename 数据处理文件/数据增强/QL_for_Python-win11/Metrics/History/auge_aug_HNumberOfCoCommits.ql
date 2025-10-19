/**
 * @name Number of co-committed files
 * @description Provides insight into the average number of additional files modified together 
 *              with a specific file in each commit
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Helper function: Determines the total count of files modified in a given commit
int calculateFilesInCommit(Commit commit) { 
    result = count(commit.getAnAffectedFile()) 
}

// Main analysis: Evaluates co-committing behavior across different modules
from Module moduleOfInterest
// Restriction: Focus only on modules that have lines of code metrics available
where exists(moduleOfInterest.getMetrics().getNumberOfLinesOfCode())
select moduleOfInterest,
  // Compute the average number of files co-committed with this module's files
  avg(Commit commitImpact |
    // Criteria: The commit must affect a file from the current module
    commitImpact.getAnAffectedFile() = moduleOfInterest.getFile()
  |
    // Calculate how many other files were modified in the same commit
    calculateFilesInCommit(commitImpact) - 1
  )