/**
 * @name Deleted lines per file
 * @description Aggregates the count of lines removed from each file throughout the entire commit history of the repository.
 *              This measurement helps in pinpointing files that have undergone significant code restructuring or feature removal.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

from Module sourceModule, int totalDeletedLines
where
  // Ensure the module has valid metrics to guarantee meaningful analysis results
  exists(sourceModule.getMetrics().getNumberOfLinesOfCode()) and
  // Calculate the aggregate count of lines deleted across all commits for this module
  totalDeletedLines = sum(Commit commit, int deletedLinesInCommit |
    // For each commit, obtain the count of lines removed from this file, disregarding automated or insignificant modifications
    deletedLinesInCommit = commit.getRecentDeletionsForFile(sourceModule.getFile()) and 
    not artificialChange(commit)
  |
    deletedLinesInCommit
  )
select sourceModule, totalDeletedLines order by totalDeletedLines desc