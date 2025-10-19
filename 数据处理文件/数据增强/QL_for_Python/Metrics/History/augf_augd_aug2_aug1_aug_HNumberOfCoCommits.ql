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

// Utility function: Determines the total count of modified files within a specific commit
int countFilesModifiedInCommit(Commit changeSet) { 
    result = count(changeSet.getAnAffectedFile()) 
}

// Primary analysis: Examines the pattern of files being modified together across various modules
from Module targetModule
// Precondition: Restrict analysis to modules that have lines-of-code metrics available
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  // Calculate the mean number of files that are modified concurrently with files in this module
  avg(Commit changeSet, int simultaneouslyChangedFiles |
    // Constraint: The commit must include at least one file from the module under examination
    changeSet.getAnAffectedFile() = targetModule.getFile() and 
    // Derive the count of other files modified in the same commit
    simultaneouslyChangedFiles = countFilesModifiedInCommit(changeSet) - 1
  |
    simultaneouslyChangedFiles
  )