/**
 * @name Deleted lines per file
 * @description Computes the cumulative count of lines removed from each Python file
 *              across the complete version control history in the database.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

// Analysis to identify Python modules and aggregate their deletion statistics
from Module sourceFile, int totalDeletions
where
  // Ensure the module has quantifiable code prior to processing
  exists(sourceFile.getMetrics().getNumberOfLinesOfCode()) and
  // Calculate the aggregate number of lines deleted across all valid commits
  totalDeletions = sum(
    // Nested query to collect deletion metrics from each applicable commit
    Commit versionCommit, int commitDeletions |
      // Establish the number of lines eliminated in this particular commit
      commitDeletions = versionCommit.getRecentDeletionsForFile(sourceFile.getFile()) and
      // Exclude commits that are synthetic or insignificant
      not artificialChange(versionCommit)
    |
      // Sum the deletion metrics
      commitDeletions
  )
// Display results sorted by deletion count in descending sequence
select sourceFile, totalDeletions order by totalDeletions desc