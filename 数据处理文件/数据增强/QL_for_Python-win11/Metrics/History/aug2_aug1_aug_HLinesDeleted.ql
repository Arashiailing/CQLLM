/**
 * @name Deleted lines per file
 * @description Provides visualization of the cumulative volume of lines removed from each source file across the entire commit timeline.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

// Calculate and retrieve source files with their total deletion metrics
from Module sourceFile, int deletionCount
where
  // Ensure the file has measurable code content before analysis
  exists(sourceFile.getMetrics().getNumberOfLinesOfCode()) and
  // Aggregate the total lines deleted across all relevant commits
  deletionCount = 
    sum(Commit versionCommit, int linesDeleted |
      // Extract the count of lines deleted in the latest commit affecting this file
      linesDeleted = versionCommit.getRecentDeletionsForFile(sourceFile.getFile()) and
      // Filter out commits that are synthetic or not representative of actual development
      not artificialChange(versionCommit)
    |
      linesDeleted
    )
select sourceFile, deletionCount order by deletionCount desc