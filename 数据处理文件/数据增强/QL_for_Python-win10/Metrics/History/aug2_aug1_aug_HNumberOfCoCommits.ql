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

// Helper function: Calculates the total number of files affected by a specific commit
int countAffectedFilesInCommit(Commit revision) { 
    result = count(revision.getAnAffectedFile()) 
}

// Main analysis: Analyzes patterns of co-modification across various modules
from Module targetModule
// Filtering condition: Only consider modules that have available lines of code metrics
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  // Calculate the average count of files modified together with files in this module
  avg(Commit commit, int coModifiedFilesCount |
    // Condition: The commit affects a file within the target module
    commit.getAnAffectedFile() = targetModule.getFile() and 
    // Compute the number of additional files modified in the same commit
    coModifiedFilesCount = countAffectedFilesInCommit(commit) - 1
  |
    coModifiedFilesCount
  )