/**
 * @name Deleted lines per file
 * @description Visualizes the cumulative count of lines removed from each source file throughout the entire commit history.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

// Identify source modules and compute their total line deletion metrics
from Module codeModule, int totalDeletions
where
  // Verify that the module contains measurable code before analysis
  exists(codeModule.getMetrics().getNumberOfLinesOfCode()) and
  // Compute the aggregate count of deleted lines across all valid commits
  totalDeletions = 
    sum(Commit changeCommit, int removedLines |
      // Obtain the number of lines deleted in each commit affecting this module
      removedLines = changeCommit.getRecentDeletionsForFile(codeModule.getFile()) and
      // Exclude artificial commits that don't represent actual development changes
      not artificialChange(changeCommit)
    |
      removedLines
    )
select codeModule, totalDeletions order by totalDeletions desc