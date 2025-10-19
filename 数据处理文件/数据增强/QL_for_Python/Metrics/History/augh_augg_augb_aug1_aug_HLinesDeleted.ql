/**
 * @name Deleted lines per file
 * @description Computes the aggregate count of lines removed from each source file throughout the entire commit history of the repository.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

// Analyze Python source files and determine the total quantity of lines eliminated across their entire revision history
from Module sourceFile, int totalDeletedLines
where
  // Validate that the source file contains quantifiable code to ensure analysis relevance
  exists(sourceFile.getMetrics().getNumberOfLinesOfCode()) and
  // Calculate the cumulative count of deleted lines for each file across all valid commits
  totalDeletedLines = sum(int linesDeletedInCommit |
      exists(Commit commitRecord |
          // Extract the count of lines removed in each commit that modifies this source file
          linesDeletedInCommit = commitRecord.getRecentDeletionsForFile(sourceFile.getFile()) and
          // Filter out synthetic commits that do not represent genuine code modifications
          not artificialChange(commitRecord)
      )
  )
select sourceFile, totalDeletedLines order by totalDeletedLines desc