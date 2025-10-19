/**
 * @name Number of re-commits for each file
 * @description Counts commits to files modified within 5 days of previous changes
 * @kind treemap
 * @id py/historical-number-of-re-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max */

import python
import external.VCS

/** Determines if two commits affect the same file within 5-day window */
predicate commitsWithinRange(Commit baseCommit, Commit followCommit) {
  baseCommit.getAnAffectedFile() = followCommit.getAnAffectedFile() and
  baseCommit != followCommit and
  exists(int dayDelta |
    dayDelta = baseCommit.getDate().daysTo(followCommit.getDate()) and
    dayDelta >= 0 and
    dayDelta < 5
  )
}

/** Calculates re-commit count for a given file */
int getRecommitCount(File targetFile) {
  result = count(Commit currentCommit |
    targetFile = currentCommit.getAnAffectedFile() and
    exists(Commit priorCommit | commitsWithinRange(priorCommit, currentCommit))
  )
}

from Module analyzedModule
where exists(analyzedModule.getMetrics().getNumberOfLinesOfCode())
select analyzedModule, getRecommitCount(analyzedModule.getFile())