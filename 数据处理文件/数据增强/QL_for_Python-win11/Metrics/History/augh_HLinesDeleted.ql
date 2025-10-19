/**
 * @name Deleted lines per file
 * @description Count of lines removed from each file throughout the revision history stored in the database.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

from Module fileModule, int deletionCount
where
  // Verify that the module has lines of code metrics
  exists(fileModule.getMetrics().getNumberOfLinesOfCode()) and
  // Compute the total deletions across all commits for this file
  deletionCount = sum(Commit revision, int linesDeleted |
    // For each commit, get the number of lines deleted for this file, excluding artificial changes
    linesDeleted = revision.getRecentDeletionsForFile(fileModule.getFile()) and 
    not artificialChange(revision)
  | linesDeleted)
select fileModule, deletionCount order by deletionCount desc