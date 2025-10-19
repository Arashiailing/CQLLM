/**
 * @name Deleted lines per file
 * @description Calculates the total number of lines deleted for each Python file throughout its entire revision history.
 *              This query analyzes the version control history to aggregate all deletions across meaningful commits.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

// This query identifies Python modules with valid code metrics and calculates their total deletion history
from Module pythonModule, int cumulativeDeletions
where
  // Filter for modules that have valid code metrics (lines of code) to ensure meaningful analysis
  exists(pythonModule.getMetrics().getNumberOfLinesOfCode()) and
  // Calculate the total number of lines deleted across all meaningful commits for this module
  cumulativeDeletions = 
    sum(Commit versionCommit, int linesDeletedInCommit |
      // For each commit, retrieve the count of lines deleted for the current file
      linesDeletedInCommit = versionCommit.getRecentDeletionsForFile(pythonModule.getFile()) and
      // Exclude artificial commits (e.g., automated changes, merges, or imports) to focus on meaningful code changes
      not artificialChange(versionCommit)
    |
      linesDeletedInCommit
    )
select pythonModule, cumulativeDeletions order by cumulativeDeletions desc