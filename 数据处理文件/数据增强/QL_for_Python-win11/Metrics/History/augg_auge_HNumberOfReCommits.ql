/**
 * @name Number of re-commits for each file
 * @description Identifies files that are frequently modified in quick succession.
 *              A re-commit is defined as a commit to a file that was previously
 *              modified within a five-day window.
 * @kind treemap
 * @id py/historical-number-of-re-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

// Import necessary modules for Python analysis and version control system access
import python
import external.VCS

/**
 * Determines if two commits to the same file occur within a specified time window.
 * @param initialCommit The earlier commit affecting a file
 * @param subsequentCommit The later commit affecting the same file
 */
predicate areCommitsWithinTimeWindow(Commit initialCommit, Commit subsequentCommit) {
  // Verify both commits affect the same file and are distinct events
  initialCommit.getAnAffectedFile() = subsequentCommit.getAnAffectedFile() and
  initialCommit != subsequentCommit and
  // Calculate and validate the time difference between commits
  exists(int daysBetweenCommits |
    daysBetweenCommits = initialCommit.getDate().daysTo(subsequentCommit.getDate()) and
    daysBetweenCommits >= 0 and  // Ensure chronological order
    daysBetweenCommits < 5       // Within 5-day window
  )
}

/**
 * Calculates the total number of re-commits for a given file.
 * @param fileToAnalyze The file for which to count re-commits
 * @return The count of commits that have a predecessor within the time window
 */
int calculateRecommitFrequency(File fileToAnalyze) {
  result =
    // Count all commits to the file that have a recent predecessor
    count(Commit analyzedCommit |
      fileToAnalyze = analyzedCommit.getAnAffectedFile() and
      exists(Commit precedingCommit | 
        areCommitsWithinTimeWindow(precedingCommit, analyzedCommit)
      )
    )
}

// Main query execution: Analyze Python modules with measurable code
from Module sourceModule
// Restrict analysis to modules with available lines-of-code metrics
where exists(sourceModule.getMetrics().getNumberOfLinesOfCode())
// Output each module along with its file's re-commit frequency
select sourceModule, calculateRecommitFrequency(sourceModule.getFile())