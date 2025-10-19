/**
 * @name Cumulative deleted lines per source file
 * @description Computes the aggregate count of lines removed from each source file throughout the complete commit history.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

// Analyze source modules and compute their accumulated line deletion statistics
from Module fileModule, int totalDeletedLines
where
  // Verify that the module contains measurable code with valid line metrics
  exists(fileModule.getMetrics().getNumberOfLinesOfCode()) and
  // Aggregate the total lines deleted across all significant commits affecting this file
  totalDeletedLines = 
    sum(Commit commitRecord, int deletedLinesPerCommit |
      // Extract the number of lines deleted in each commit that modified this file
      deletedLinesPerCommit = commitRecord.getRecentDeletionsForFile(fileModule.getFile()) and
      // Exclude artificial or trivial commits that don't represent meaningful changes
      not artificialChange(commitRecord)
    |
      deletedLinesPerCommit
    )
select fileModule, totalDeletedLines order by totalDeletedLines desc