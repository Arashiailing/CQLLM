/**
 * @name Co-committed files analysis
 * @description Calculates the average number of files that are modified together with each file
 *              across all commits affecting that file
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Helper function to count total files affected in a specific commit
int countAffectedFilesInCommit(Commit cm) { 
    result = count(cm.getAnAffectedFile()) 
}

// Main analysis query
from Module moduleObj
// Restrict to modules that have lines of code metrics available
where exists(moduleObj.getMetrics().getNumberOfLinesOfCode())
select moduleObj,
  // Calculate average co-committed files for this module
  avg(Commit cm, int coCommittedCount |
    // Find commits that affect this module's file
    cm.getAnAffectedFile() = moduleObj.getFile() and
    // Calculate co-committed files (total affected files minus the module file itself)
    coCommittedCount = countAffectedFilesInCommit(cm) - 1
  |
    coCommittedCount
  )