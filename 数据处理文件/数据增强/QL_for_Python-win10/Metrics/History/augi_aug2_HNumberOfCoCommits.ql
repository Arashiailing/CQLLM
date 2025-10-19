/**
 * @name Co-committed files analysis
 * @description Analyzes the average number of files that are modified together with each file
 *              across all commits affecting that file, providing insight into code coupling
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Helper function to determine the total number of files affected in a specific commit
int getTotalFilesModifiedInCommit(Commit commit) { 
    result = count(commit.getAnAffectedFile()) 
}

// Primary analysis for co-committed files
from Module targetModule
// Filter to modules that have available lines of code metrics
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  // Compute the average count of files modified together with this module's file
  avg(Commit commit, int coModifiedFilesCount |
    // Identify commits that affect the current module's file
    commit.getAnAffectedFile() = targetModule.getFile() and
    // Calculate the number of co-modified files (total affected files minus the module file itself)
    coModifiedFilesCount = getTotalFilesModifiedInCommit(commit) - 1
  |
    coModifiedFilesCount
  )