/**
 * @name File Deletion Analysis
 * @description Quantifies the total number of lines deleted per file throughout the entire commit history stored in the database.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

// Identify source code modules and compute their cumulative deletion metrics
from Module fileModule, int totalDeletions
where
  // Aggregate deletion statistics across all commits for each file
  totalDeletions = 
    sum(Commit codeCommit, int removedLines |
      // Extract line deletion data from the most recent commit affecting each file
      removedLines = codeCommit.getRecentDeletionsForFile(fileModule.getFile()) and
      // Exclude commits that are not actual code changes (e.g., automated refactorings)
      not artificialChange(codeCommit)
    |
      removedLines
    ) and
  // Ensure code metrics are available for proper analysis of this module
  exists(fileModule.getMetrics().getNumberOfLinesOfCode())
select fileModule, totalDeletions order by totalDeletions desc