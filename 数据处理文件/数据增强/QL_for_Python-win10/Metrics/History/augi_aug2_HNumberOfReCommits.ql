/**
 * @name Number of re-commits for each file
 * @description Counts commits to files modified within the last 5 days
 * @kind treemap
 * @id py/historical-number-of-re-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

/**
 * Determines if two commits target the same file within a 5-day window
 */
predicate commitsInTimeWindow(Commit priorCommit, Commit subsequentCommit) {
  // Ensure commits affect the same file and are distinct
  priorCommit.getAnAffectedFile() = subsequentCommit.getAnAffectedFile() and
  priorCommit != subsequentCommit and
  // Calculate and validate time window (0 ≤ days < 5)
  exists(int timeDelta |
    timeDelta = priorCommit.getDate().daysTo(subsequentCommit.getDate()) and
    timeDelta >= 0 and
    timeDelta < 5
  )
}

/**
 * Calculates re-commit count for a specific file
 */
int calculateRecommitCount(File analyzedFile) {
  result = count(Commit currentCommit |
    // Verify commit affects target file
    analyzedFile = currentCommit.getAnAffectedFile() and
    // Check existence of prior commit within time window
    exists(Commit priorCommit | 
      commitsInTimeWindow(priorCommit, currentCommit)
    )
  )
}

from Module sourceModule
// Filter modules with measurable code content
where exists(sourceModule.getMetrics().getNumberOfLinesOfCode())
select sourceModule, calculateRecommitCount(sourceModule.getFile())