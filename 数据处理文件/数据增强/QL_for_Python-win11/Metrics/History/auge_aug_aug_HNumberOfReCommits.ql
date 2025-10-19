/**
 * @name File Re-commit Frequency Analysis
 * @description Calculates the frequency of re-commits for files, where a re-commit is defined as 
 *              a modification to a file within 5 days of a previous modification to the same file.
 * @kind treemap
 * @id py/historical-number-of-re-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Predicate to determine if two commits to the same file occur within a 5-day timeframe
predicate isRecommitWindow(Commit earlierCommit, Commit laterCommit) {
  // Ensure commits are distinct but affect the same file
  earlierCommit != laterCommit and
  earlierCommit.getAnAffectedFile() = laterCommit.getAnAffectedFile() and
  // Calculate and validate the time interval between commits
  exists(int daysBetweenCommits | 
    daysBetweenCommits = earlierCommit.getDate().daysTo(laterCommit.getDate()) and
    daysBetweenCommits >= 0 and daysBetweenCommits < 5
  )
}

// Function to compute the total number of re-commits for a specific file
int calculateRecommitFrequency(File targetFile) {
  result = count(Commit currentCommit |
    // Verify the current commit affects our target file
    targetFile = currentCommit.getAnAffectedFile() and
    // Confirm there's a preceding commit within the re-commit window
    exists(Commit previousCommit | isRecommitWindow(previousCommit, currentCommit))
  )
}

// Main query to fetch modules with LOC metrics and their re-commit frequencies
from Module sourceModule
where exists(sourceModule.getMetrics().getNumberOfLinesOfCode())
select sourceModule, calculateRecommitFrequency(sourceModule.getFile())