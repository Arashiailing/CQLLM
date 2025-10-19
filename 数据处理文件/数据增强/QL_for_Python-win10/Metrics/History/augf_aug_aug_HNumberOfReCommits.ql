/**
 * @name Number of re-commits for each file
 * @description Quantifies re-commits where a file undergoes modifications again within a 5-day window after a previous commit
 * @kind treemap
 * @id py/historical-number-of-re-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Evaluates if two commits affecting the same file fall within the re-commit timeframe
predicate commitsWithinWindow(Commit firstCommit, Commit nextCommit) {
  // Commits must be distinct but modify the same file
  firstCommit != nextCommit and
  firstCommit.getAnAffectedFile() = nextCommit.getAnAffectedFile() and
  // Calculate and verify the time difference is within 0-4 days
  exists(int dayDifference | 
    dayDifference = firstCommit.getDate().daysTo(nextCommit.getDate()) and
    dayDifference >= 0 and dayDifference < 5
  )
}

// Computes total re-commit occurrences for a specified file
int getRecommitCount(File targetFile) {
  result = count(Commit examinedCommit |
    // Commit must modify the target file
    targetFile = examinedCommit.getAnAffectedFile() and
    // Requires a preceding commit within the time window
    exists(Commit earlierCommit | commitsWithinWindow(earlierCommit, examinedCommit))
  )
}

// Query modules with LOC metrics and their re-commit frequencies
from Module selectedModule
where exists(selectedModule.getMetrics().getNumberOfLinesOfCode())
select selectedModule, getRecommitCount(selectedModule.getFile())