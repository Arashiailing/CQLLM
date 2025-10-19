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
 * Checks if two commits affect the same file within a 5-day window
 * @param initialCommit - The first commit that modified a file
 * @param subsequentCommit - A later commit that modified the same file
 */
predicate commitsWithinRange(Commit initialCommit, Commit subsequentCommit) {
  // Both commits must affect the same file and be different commits
  initialCommit.getAnAffectedFile() = subsequentCommit.getAnAffectedFile() and
  initialCommit != subsequentCommit and
  
  // Calculate the time difference between commits
  exists(int daysDifference |
    daysDifference = initialCommit.getDate().daysTo(subsequentCommit.getDate()) and
    // Ensure time difference is within 5-day window (0 to 4 days)
    daysDifference >= 0 and
    daysDifference < 5
  )
}

/**
 * Computes the number of times a file was re-committed within 5 days
 * of a previous modification
 * @param fileOfInterest - The file to analyze for re-commits
 */
int getRecommitCount(File fileOfInterest) {
  // Count all commits to the file that have a prior commit within 5 days
  result = count(Commit recentCommit |
    fileOfInterest = recentCommit.getAnAffectedFile() and
    exists(Commit earlierCommit | 
      commitsWithinRange(earlierCommit, recentCommit)
    )
  )
}

// Select modules with measurable code and their re-commit counts
from Module moduleUnderAnalysis
where exists(moduleUnderAnalysis.getMetrics().getNumberOfLinesOfCode())
select moduleUnderAnalysis, getRecommitCount(moduleUnderAnalysis.getFile())