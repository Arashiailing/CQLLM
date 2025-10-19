/**
 * @name Co-committed Files Count
 * @description Calculates the average number of additional files modified in commits 
 *              that also affect a specific file. This metric helps identify files 
 *              that are frequently modified together, indicating potential 
 *              coupling or dependencies.
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Helper function that computes the total number of files affected in a specific commit
int calculateTotalFilesInCommit(Commit c) { 
    result = count(c.getAnAffectedFile()) 
}

// Main query logic: analyze modules with line count metrics
from Module targetModule
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  // Calculate average number of co-committed files for each module
  avg(Commit relevantCommit, int coCommittedFilesCount |
    // Filter to commits affecting the module's file and compute co-commit count
    relevantCommit.getAnAffectedFile() = targetModule.getFile() and 
    coCommittedFilesCount = calculateTotalFilesInCommit(relevantCommit) - 1
  |
    coCommittedFilesCount
  )