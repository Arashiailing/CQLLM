/**
 * @name Deleted lines per file
 * @description Calculates the total number of lines deleted from each source file across all commits in the repository history.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

// Identify source files and calculate their cumulative line deletion metrics
from Module sourceFile, int totalDeletions
where
  // Ensure the source file has measurable code content before analysis
  exists(sourceFile.getMetrics().getNumberOfLinesOfCode()) and
  // Aggregate the total lines deleted across all valid commits for this file
  totalDeletions = sum(Commit commitEntry, int linesDeleted |
      // Extract the count of lines removed in each commit affecting this file
      linesDeleted = commitEntry.getRecentDeletionsForFile(sourceFile.getFile()) and
      // Filter out commits that are synthetic or not representative of actual changes
      not artificialChange(commitEntry)
    | 
      linesDeleted
    )
select sourceFile, totalDeletions order by totalDeletions desc