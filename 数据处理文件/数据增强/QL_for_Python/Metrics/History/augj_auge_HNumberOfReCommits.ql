/**
 * @name Number of re-commits for each file
 * @description This metric counts commits to a file that was previously modified within a five-day window.
 * @kind treemap
 * @id py/historical-number-of-re-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

// Import Python and version control system modules
import python
import external.VCS

// Define predicate to determine if two commits are within a five-day time window
predicate areCommitsWithinTimeWindow(Commit precedingCommit, Commit succeedingCommit) {
  // Both commits must affect the same file and be distinct commits
  precedingCommit.getAnAffectedFile() = succeedingCommit.getAnAffectedFile() and
  precedingCommit != succeedingCommit and
  // Calculate the time difference between commits
  exists(int daysBetweenCommits |
    daysBetweenCommits = precedingCommit.getDate().daysTo(succeedingCommit.getDate()) and
    // Ensure the time difference is between 0 and 4 days (inclusive)
    daysBetweenCommits >= 0 and
    daysBetweenCommits < 5
  )
}

// Function to calculate the number of re-commits for a given file
int calculateRecommitCount(File fileToAnalyze) {
  result =
    // Count all commits that affect the file and have a recent preceding commit
    count(Commit analyzedCommit |
      fileToAnalyze = analyzedCommit.getAnAffectedFile() and
      // Check if there exists a preceding commit within the time window
      exists(Commit precedingCommitForFile | 
        areCommitsWithinTimeWindow(precedingCommitForFile, analyzedCommit)
      )
    )
}

// Main query that selects Python modules with lines-of-code metrics
from Module pythonModule
// Filter to include only modules that have lines-of-code measurements
where exists(pythonModule.getMetrics().getNumberOfLinesOfCode())
// Output the module and the re-commit count for its associated file
select pythonModule, calculateRecommitCount(pythonModule.getFile())