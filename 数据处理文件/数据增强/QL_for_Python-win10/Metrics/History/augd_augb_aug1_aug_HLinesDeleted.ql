/**
 * @name Deleted lines per file
 * @description Computes the cumulative count of lines removed from each source file throughout the entire commit history of the repository.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

// Identify code modules and calculate their cumulative line deletion metrics
from Module codeModule, int cumulativeDeletions
where
  // Verify that the code module contains measurable code content
  exists(codeModule.getMetrics().getNumberOfLinesOfCode()) and
  // Compute the total lines deleted across all authentic commits for this module
  cumulativeDeletions = sum(int deletedLines |
      // For each commit that affects this file, extract the number of deleted lines
      exists(Commit revision |
        deletedLines = revision.getRecentDeletionsForFile(codeModule.getFile()) and
        // Exclude artificial commits that don't represent actual code changes
        not artificialChange(revision)
      )
    )
select codeModule, cumulativeDeletions order by cumulativeDeletions desc