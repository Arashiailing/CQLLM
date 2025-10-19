/**
 * @name Deleted lines per file
 * @description Number of deleted lines per file, across the revision history in the database.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

// Identify Python modules and compute their total deletion metrics
from Module fileModule, int totalDeletedLines
where
  // Ensure the module has valid code metrics before processing
  exists(fileModule.getMetrics().getNumberOfLinesOfCode()) and
  // Aggregate deletion counts across all relevant commits
  totalDeletedLines = 
    sum(Commit commitRecord, int deletedLinesCount |
      // Extract the number of lines deleted in each commit
      deletedLinesCount = commitRecord.getRecentDeletionsForFile(fileModule.getFile()) and
      // Exclude commits that are artificial or not meaningful
      not artificialChange(commitRecord)
    |
      deletedLinesCount
    )
select fileModule, totalDeletedLines order by totalDeletedLines desc