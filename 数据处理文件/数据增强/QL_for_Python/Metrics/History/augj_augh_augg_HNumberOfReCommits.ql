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

/**
 * Determines if two commits modify the same file within a 5-day timeframe
 * @param firstCommit - The initial commit that modified a file
 * @param secondCommit - A subsequent commit that modified the same file
 */
predicate isCommitInRecommitWindow(Commit firstCommit, Commit secondCommit) {
  // Both commits must target the same file and be distinct commits
  firstCommit.getAnAffectedFile() = secondCommit.getAnAffectedFile() and
  firstCommit != secondCommit and
  
  // Calculate the temporal distance between commits
  exists(int timeDelta |
    timeDelta = firstCommit.getDate().daysTo(secondCommit.getDate()) and
    // Verify the time difference falls within the 5-day window (0 to 4 days)
    timeDelta >= 0 and
    timeDelta < 5
  )
}

/**
 * Calculates the frequency of re-commits for a specific file within 5 days
 * of a prior modification
 * @param targetFile - The file to analyze for re-commit patterns
 */
int calculateRecommitFrequency(File targetFile) {
  // Count all commits to the file that have a preceding commit within 5 days
  result = count(Commit currentCommit |
    targetFile = currentCommit.getAnAffectedFile() and
    exists(Commit previousCommit | 
      isCommitInRecommitWindow(previousCommit, currentCommit)
    )
  )
}

// Query to find modules with measurable code and their re-commit frequencies
from Module analyzedModule
where exists(analyzedModule.getMetrics().getNumberOfLinesOfCode())
select analyzedModule, calculateRecommitFrequency(analyzedModule.getFile())