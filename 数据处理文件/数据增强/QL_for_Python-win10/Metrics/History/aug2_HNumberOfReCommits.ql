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
predicate commitsInTimeWindow(Commit earlierCommit, Commit laterCommit) {
  // Both commits must affect the same file and be distinct
  earlierCommit.getAnAffectedFile() = laterCommit.getAnAffectedFile() and
  earlierCommit != laterCommit and
  // Calculate days between commits (0 ≤ days < 5)
  exists(int daysBetween |
    daysBetween = earlierCommit.getDate().daysTo(laterCommit.getDate()) and
    daysBetween >= 0 and
    daysBetween < 5
  )
}

/**
 * Calculates re-commit count for a specific file
 */
int countRecommits(File targetFile) {
  result = count(Commit currentCommit |
    // Current commit affects the target file
    targetFile = currentCommit.getAnAffectedFile() and
    // Exists a previous commit within the time window
    exists(Commit previousCommit | 
      commitsInTimeWindow(previousCommit, currentCommit)
    )
  )
}

from Module m
// Only consider modules with measurable code
where exists(m.getMetrics().getNumberOfLinesOfCode())
select m, countRecommits(m.getFile())