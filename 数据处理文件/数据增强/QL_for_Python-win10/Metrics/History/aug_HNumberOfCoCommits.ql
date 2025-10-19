/**
 * @name Number of co-committed files
 * @description The average number of other files that are touched whenever a file is affected by a commit
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Helper function: Calculates total files affected in a specific commit
int countAffectedFiles(Commit commit) { 
    result = count(commit.getAnAffectedFile()) 
}

// Main query: Analyzes co-commit patterns for each module
from Module targetModule
// Filter condition: Only consider modules with lines of code metrics available
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  // Calculate average co-committed files for each module
  avg(Commit affectingCommit, int coCommitCount |
    // Condition: Commit affects current module file, calculate other files in same commit
    affectingCommit.getAnAffectedFile() = targetModule.getFile() and 
    coCommitCount = countAffectedFiles(affectingCommit) - 1
  |
    coCommitCount
  )