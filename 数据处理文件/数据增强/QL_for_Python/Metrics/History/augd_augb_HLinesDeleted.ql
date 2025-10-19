/**
 * @name Deleted lines per file
 * @description Calculates the total number of lines deleted for each file throughout 
 *              the revision history stored in the database.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

from Module sourceModule, int cumulativeDeletedCount
where
  // Verify that the module has available code metrics data
  exists(sourceModule.getMetrics().getNumberOfLinesOfCode()) and
  // Calculate the cumulative count of deleted lines for each module across all commits
  cumulativeDeletedCount =
    sum(Commit commitRecord, int deletedLines |
      // For each commit, retrieve the number of lines deleted from the file
      deletedLines = commitRecord.getRecentDeletionsForFile(sourceModule.getFile()) and 
      // Exclude artificial or automated changes from the count
      not artificialChange(commitRecord)
    |
      deletedLines
    )
select sourceModule, cumulativeDeletedCount order by cumulativeDeletedCount desc