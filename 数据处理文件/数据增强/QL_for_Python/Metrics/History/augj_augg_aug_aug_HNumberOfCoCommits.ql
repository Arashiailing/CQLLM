/**
 * @name Co-committed Files Count
 * @description Measures the average quantity of extra files changed within commits 
 *              that touch a particular file. This metric assists in recognizing files 
 *              that undergo simultaneous modifications often, suggesting possible 
 *              code relationships or interdependencies.
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Utility function to compute the total number of files impacted by a given commit
int calculateFilesInCommit(Commit commit) { 
    result = count(commit.getAnAffectedFile()) 
}

// Core analysis: process modules containing line count data to identify co-commit behavior
from Module targetModule
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  // Compute the mean count of co-committed files for each target module
  avg(Commit commitInvolvingModule, int additionalFilesCount |
    // Identify commits that modify the module's file and determine the co-commit quantity
    commitInvolvingModule.getAnAffectedFile() = targetModule.getFile() and 
    additionalFilesCount = calculateFilesInCommit(commitInvolvingModule) - 1
  |
    additionalFilesCount
  )