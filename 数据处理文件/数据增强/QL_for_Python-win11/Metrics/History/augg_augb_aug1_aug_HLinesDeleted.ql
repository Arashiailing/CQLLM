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

// Identify Python modules and compute the aggregate count of lines removed across their commit history
from Module targetModule, int cumulativeDeletions
where
  // Verify that the module contains measurable code to ensure meaningful analysis
  exists(targetModule.getMetrics().getNumberOfLinesOfCode()) and
  // Compute the sum of deleted lines for each file across all legitimate commits
  cumulativeDeletions = sum(int removedLines |
      exists(Commit revision |
          // Determine the number of lines deleted in each commit that affects this module
          removedLines = revision.getRecentDeletionsForFile(targetModule.getFile()) and
          // Exclude artificial commits that don't represent actual code changes
          not artificialChange(revision)
      )
  )
select targetModule, cumulativeDeletions order by cumulativeDeletions desc