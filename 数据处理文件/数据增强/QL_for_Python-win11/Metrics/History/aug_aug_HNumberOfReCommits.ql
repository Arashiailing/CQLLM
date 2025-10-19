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

// Predicate to evaluate if two commits fall within the defined re-commit timeframe
predicate commitsWithinWindow(Commit initialCommit, Commit subsequentCommit) {
  // Commits must refer to distinct revisions but impact the same file
  initialCommit != subsequentCommit and
  initialCommit.getAnAffectedFile() = subsequentCommit.getAnAffectedFile() and
  // Compute the temporal gap between commits and verify it's within the 0-4 day range
  exists(int temporalGap | 
    temporalGap = initialCommit.getDate().daysTo(subsequentCommit.getDate()) and
    temporalGap >= 0 and temporalGap < 5
  )
}

// Determine the aggregate count of re-commits for a given file
int getRecommitCount(File fileOfInterest) {
  result = count(Commit analyzedCommit |
    // The analyzed commit must involve the file of interest
    fileOfInterest = analyzedCommit.getAnAffectedFile() and
    // There must exist a preceding commit within the re-commit window
    exists(Commit precedingCommit | commitsWithinWindow(precedingCommit, analyzedCommit))
  )
}

// Retrieve modules with LOC metrics along with their corresponding re-commit frequencies
from Module moduleOfInterest
where exists(moduleOfInterest.getMetrics().getNumberOfLinesOfCode())
select moduleOfInterest, getRecommitCount(moduleOfInterest.getFile())