/**
 * @name File Deletion Analysis
 * @description Identifies files with the highest cumulative line deletions across the repository's commit history.
 *              This analysis helps pinpoint files that have undergone significant refactoring or feature removal.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

from Module sourceFile, int totalDeletions
where
  // Validate that the source file has measurable code metrics
  exists(sourceFile.getMetrics().getNumberOfLinesOfCode()) and
  // Calculate the total lines deleted from this file across all commits
  totalDeletions = sum(Commit commit, int deletedLinesInCommit |
    // For each commit, count lines deleted from the file, excluding artificial changes
    deletedLinesInCommit = commit.getRecentDeletionsForFile(sourceFile.getFile()) and 
    not artificialChange(commit)
  |
    deletedLinesInCommit
  )
select sourceFile, totalDeletions order by totalDeletions desc