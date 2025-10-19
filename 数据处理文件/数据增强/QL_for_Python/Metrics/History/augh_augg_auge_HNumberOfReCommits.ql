/**
 * @name Frequency of rapid re-commits per file
 * @description Detects files undergoing frequent modifications in short timeframes.
 *              A re-commit occurs when a file is modified again within five days
 *              of a previous modification to the same file.
 * @kind treemap
 * @id py/historical-number-of-re-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

// Import required modules for Python code analysis and version control system integration
import python
import external.VCS

/**
 * Checks whether two commits affecting the same file fall within a defined time period.
 * @param firstCommit The initial commit that modified a file
 * @param secondCommit The subsequent commit that modified the same file
 */
predicate commitsInTimeframe(Commit firstCommit, Commit secondCommit) {
  // Ensure both commits target the same file and represent different changes
  firstCommit.getAnAffectedFile() = secondCommit.getAnAffectedFile() and
  firstCommit != secondCommit and
  // Compute and verify the temporal gap between commits
  exists(int timeDelta |
    timeDelta = firstCommit.getDate().daysTo(secondCommit.getDate()) and
    timeDelta >= 0 and  // Confirm proper chronological sequence
    timeDelta < 5       // Falls within 5-day timeframe
  )
}

/**
 * Computes the total count of re-commits for a specified file.
 * @param targetFile The file to analyze for re-commit patterns
 * @return The number of commits that have a preceding commit within the timeframe
 */
int getRecommitCount(File targetFile) {
  result =
    // Tally all commits to the file with a recent predecessor
    count(Commit currentCommit |
      targetFile = currentCommit.getAnAffectedFile() and
      exists(Commit priorCommit | 
        commitsInTimeframe(priorCommit, currentCommit)
      )
    )
}

// Primary query execution: Process Python modules with quantifiable code
from Module moduleToAnalyze
// Limit analysis to modules where lines-of-code metrics are available
where exists(moduleToAnalyze.getMetrics().getNumberOfLinesOfCode())
// Display each module alongside its associated file's re-commit frequency
select moduleToAnalyze, getRecommitCount(moduleToAnalyze.getFile())