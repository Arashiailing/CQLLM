/**
 * @name Number of co-committed files
 * @description Calculates the average number of files modified together when a specific file is changed in a commit
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Helper function: Computes the total number of files modified in a given commit
int getTotalFilesInCommit(Commit commit) { 
    result = count(commit.getAnAffectedFile()) 
}

// Main analysis: Evaluates co-modification patterns across different modules
from Module analyzedModule
// Filtering condition: Only process modules with available lines-of-code metrics
where exists(analyzedModule.getMetrics().getNumberOfLinesOfCode())
select analyzedModule,
  // Compute the average count of files modified alongside files in this module
  avg(Commit commit, int coModifiedCount |
    // Condition: The commit affects a file within the analyzed module
    commit.getAnAffectedFile() = analyzedModule.getFile() and 
    // Calculate the number of additional files modified in the same commit
    coModifiedCount = getTotalFilesInCommit(commit) - 1
  |
    coModifiedCount
  )