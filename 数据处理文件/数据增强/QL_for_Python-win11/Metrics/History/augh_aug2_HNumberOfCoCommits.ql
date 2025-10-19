/**
 * @name Co-committed files analysis
 * @description Computes the mean count of files modified alongside each file
 *              across all commits that modify the file
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Helper function: determine total modified files in a commit
int getCommitFileCount(Commit commit) { 
    result = count(commit.getAnAffectedFile()) 
}

// Core analysis logic
from Module targetModule
// Filter to modules with available code metrics
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  // Calculate average co-modified files per commit
  avg(Commit commit, int coModifiedCount |
    // Identify commits affecting the target file
    commit.getAnAffectedFile() = targetModule.getFile() and
    // Compute co-modified files (total files minus the target file)
    coModifiedCount = getCommitFileCount(commit) - 1
  |
    coModifiedCount
  )