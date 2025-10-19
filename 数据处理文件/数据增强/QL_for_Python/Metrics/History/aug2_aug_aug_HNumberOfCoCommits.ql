/**
 * @name Co-committed Files Analysis
 * @description Measures the average quantity of extra files altered in commits 
 *              that also modify a particular file. This metric helps discover 
 *              files that are often changed concurrently, suggesting possible 
 *              relationships or dependencies between them.
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Helper function that determines the count of files modified in a given commit
int computeFilesAffectedInCommit(Commit commitObj) { 
    result = count(commitObj.getAnAffectedFile()) 
}

// Main analysis: examine modules with line count statistics
from Module analyzedModule
where exists(analyzedModule.getMetrics().getNumberOfLinesOfCode())
select analyzedModule,
  // Compute the mean number of co-modified files for each module
  avg(Commit commitInstance, int coChangedFilesCount |
    // Identify commits that modify the module's file and calculate co-change count
    commitInstance.getAnAffectedFile() = analyzedModule.getFile() and 
    coChangedFilesCount = computeFilesAffectedInCommit(commitInstance) - 1
  |
    coChangedFilesCount
  )