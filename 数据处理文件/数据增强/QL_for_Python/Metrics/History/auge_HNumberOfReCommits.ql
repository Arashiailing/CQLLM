/**
 * @name Number of re-commits for each file
 * @description A re-commit is taken to mean a commit to a file that was touched less than five days ago.
 * @kind treemap
 * @id py/historical-number-of-re-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

// Import Python and version control system modules
import python
import external.VCS

// Define predicate to check if two commits are within the specified time window
predicate commitsInRange(Commit earlierCommit, Commit laterCommit) {
  // Ensure commits affect the same file and are distinct
  earlierCommit.getAnAffectedFile() = laterCommit.getAnAffectedFile() and
  earlierCommit != laterCommit and
  // Calculate days between commits and verify within 0-4 day range
  exists(int dayDelta |
    dayDelta = earlierCommit.getDate().daysTo(laterCommit.getDate()) and
    dayDelta >= 0 and
    dayDelta < 5
  )
}

// Calculate re-commit count for a specific file
int getRecommitCount(File targetFile) {
  result =
    // Count commits affecting the target file with a recent predecessor
    count(Commit currentCommit |
      targetFile = currentCommit.getAnAffectedFile() and
      exists(Commit previousCommit | 
        commitsInRange(previousCommit, currentCommit)
      )
    )
}

// Main query selecting modules with LOC metrics
from Module m
// Filter modules having lines-of-code measurements
where exists(m.getMetrics().getNumberOfLinesOfCode())
// Output module and its file's re-commit count
select m, getRecommitCount(m.getFile())