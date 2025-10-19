/**
 * @name Concurrent File Modifications Analysis
 * @description Identifies architectural connections by calculating the average number 
 *              of files modified together with a specific target file. This metric 
 *              reveals code dependencies through co-modification patterns in commits.
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Helper function: computes total file modifications in a given commit
int countFilesInCommit(Commit commit) { 
    result = count(commit.getAnAffectedFile()) 
}

// Primary analysis: evaluate modules with available line metrics
from Module moduleOfInterest
where exists(moduleOfInterest.getMetrics().getNumberOfLinesOfCode())
select moduleOfInterest,
  // Compute average co-modified files per module
  avg(Commit commit, int coChangeCount |
    // Filter commits affecting target module and calculate co-change metrics
    commit.getAnAffectedFile() = moduleOfInterest.getFile() and 
    coChangeCount = countFilesInCommit(commit) - 1
  |
    coChangeCount
  )