/**
 * @name Deleted lines per file
 * @description Calculates the total number of lines removed from each file across the entire revision history.
 *              This metric helps identify files that have undergone significant refactoring or cleanup.
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
  // Ensure the file has valid lines of code metrics available
  exists(sourceFile.getMetrics().getNumberOfLinesOfCode()) and
  // Calculate the cumulative deletions for this file across all relevant commits
  totalDeletions = sum(Commit commit, int deletedLines |
    // For each commit, retrieve the number of lines deleted from this specific file
    deletedLines = commit.getRecentDeletionsForFile(sourceFile.getFile()) and 
    // Exclude artificial changes (e.g., automated formatting, import reordering)
    not artificialChange(commit)
  | deletedLines)
select sourceFile, totalDeletions order by totalDeletions desc