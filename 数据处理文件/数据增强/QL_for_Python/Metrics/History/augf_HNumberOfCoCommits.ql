/**
 * @name Number of co-committed files
 * @description Measures the average count of additional files modified together
 *              with a specific file in the same commit. This indicates file
 *              coupling patterns and co-change relationships in the codebase.
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Helper function to determine the total number of files affected in a commit
int countAffectedFiles(Commit codeCommit) { 
    result = count(codeCommit.getAnAffectedFile()) 
}

// Query processing starts from each module in the codebase
from Module moduleObj
// Restrict analysis to modules that have lines of code metrics available
where exists(moduleObj.getMetrics().getNumberOfLinesOfCode())
select moduleObj,
  // Calculate the average number of co-committed files for this module
  avg(Commit codeCommit, int associatedFileCount |
    // Identify commits that affect the current module's file
    codeCommit.getAnAffectedFile() = moduleObj.getFile() and 
    // Compute how many other files were committed alongside this file
    associatedFileCount = countAffectedFiles(codeCommit) - 1
  |
    associatedFileCount
  )