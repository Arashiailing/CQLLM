/**
 * @name Number of co-committed files
 * @description Calculates the average number of files modified together when a specific file is changed in a commit.
 *              This metric identifies files frequently modified together, indicating potential dependencies.
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Helper function: Computes the total count of files affected by a given commit
int calculateTotalFilesInCommit(Commit commitObj) { 
    result = count(commitObj.getAnAffectedFile()) 
}

// Main analysis: Examines co-modification patterns across different modules
from Module analyzedModule
// Filtering condition: Only include modules that have available lines of code metrics
where exists(analyzedModule.getMetrics().getNumberOfLinesOfCode())
select analyzedModule,
  // Determine the average count of files modified together with files in this module
  avg(Commit commitObj, int coChangedFilesNumber |
    // Condition: The commit affects a file within the analyzed module
    commitObj.getAnAffectedFile() = analyzedModule.getFile() and 
    // Calculate the number of additional files modified in the same commit
    coChangedFilesNumber = calculateTotalFilesInCommit(commitObj) - 1
  |
    coChangedFilesNumber
  )