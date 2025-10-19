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

// Predicate to check if two commits fall within the re-commit time window (5 days)
predicate isWithinRecommitWindow(Commit priorCommit, Commit subsequentCommit) {
  // Ensure both commits affect the same file and are different commits
  priorCommit.getAnAffectedFile() = subsequentCommit.getAnAffectedFile() and
  priorCommit != subsequentCommit and
  // Calculate the time difference between commits (must be 0-4 days)
  exists(int dayDifference |
    dayDifference = priorCommit.getDate().daysTo(subsequentCommit.getDate()) and
    dayDifference >= 0 and
    dayDifference < 5
  )
}

// Function to compute the total number of re-commits for a specific file
int calculateRecommitCount(File fileOfInterest) {
  // Count all commits that qualify as re-commits to the file of interest
  result = count(Commit currentCommit |
    // The commit must affect the file we're analyzing
    fileOfInterest = currentCommit.getAnAffectedFile() and
    // There must exist a previous commit within the re-commit window
    exists(Commit earlierCommit | 
      isWithinRecommitWindow(earlierCommit, currentCommit)
    )
  )
}

// Query modules that have available code metrics
from Module codeModule
// Filter to include only modules with lines-of-code metrics available
where exists(codeModule.getMetrics().getNumberOfLinesOfCode())
// Select the module and its calculated re-commit count
select codeModule, calculateRecommitCount(codeModule.getFile())