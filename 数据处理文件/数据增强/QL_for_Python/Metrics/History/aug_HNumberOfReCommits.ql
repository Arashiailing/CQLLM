/**
 * @name Number of re-commits for each file
 * @description Counts re-commits (commits to files modified within the last 5 days)
 * @kind treemap
 * @id py/historical-number-of-re-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

// Import Python and external version control system libraries
import python
import external.VCS

// Predicate to determine if two commits are within the re-commit time window
predicate commitsInRange(Commit earlierCommit, Commit laterCommit) {
  // Both commits must affect the same file and be distinct
  earlierCommit.getAnAffectedFile() = laterCommit.getAnAffectedFile() and
  earlierCommit != laterCommit and
  // Calculate days between commits (must be 0-4 days)
  exists(int daysBetween |
    daysBetween = earlierCommit.getDate().daysTo(laterCommit.getDate()) and
    daysBetween >= 0 and
    daysBetween < 5
  )
}

// Calculate total re-commits for a given file
int countRecommits(File targetFile) {
  // Count all commits that qualify as re-commits
  result = count(Commit subsequentCommit |
    // Commit affects the target file
    targetFile = subsequentCommit.getAnAffectedFile() and
    // Exists a previous commit within re-commit window
    exists(Commit previousCommit | 
      commitsInRange(previousCommit, subsequentCommit)
    )
  )
}

// Query modules with available code metrics
from Module sourceModule
// Ensure module has lines-of-code metrics available
where exists(sourceModule.getMetrics().getNumberOfLinesOfCode())
// Select module and its re-commit count
select sourceModule, countRecommits(sourceModule.getFile())