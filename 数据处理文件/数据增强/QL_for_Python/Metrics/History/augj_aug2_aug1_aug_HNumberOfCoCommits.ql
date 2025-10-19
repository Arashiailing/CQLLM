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

// Helper: Computes total modified files in a commit
int getCommitFileCount(Commit commit) { 
    result = count(commit.getAnAffectedFile()) 
}

// Main analysis: Evaluates co-modification patterns across modules
from Module analyzedModule
// Filter: Only process modules with available lines-of-code metrics
where exists(analyzedModule.getMetrics().getNumberOfLinesOfCode())
select analyzedModule,
  // Calculate average co-modified files when this module's files are changed
  avg(Commit commit, int coCommitCount |
    // Condition: Commit affects a file within the analyzed module
    commit.getAnAffectedFile() = analyzedModule.getFile() and 
    // Compute additional files modified in the same commit
    coCommitCount = getCommitFileCount(commit) - 1
  |
    coCommitCount
  )