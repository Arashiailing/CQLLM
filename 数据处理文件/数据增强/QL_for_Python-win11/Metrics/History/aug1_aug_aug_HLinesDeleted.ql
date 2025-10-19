/**
 * @name Deleted lines per file
 * @description Quantifies the cumulative line deletions per file across the entire commit history.
 *              This analysis helps identify files that have undergone significant refactoring or 
 *              feature removal, potentially indicating architectural changes or deprecated functionality.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

from Module sourceModule, int totalDeletedLines
where
  // Validate that the module has meaningful metrics before processing
  exists(sourceModule.getMetrics().getNumberOfLinesOfCode()) and
  // Calculate the aggregate count of lines removed from this module throughout commit history
  totalDeletedLines = sum(Commit revision, int deletionCount |
    // For each revision, obtain the number of lines deleted from this specific module
    deletionCount = revision.getRecentDeletionsForFile(sourceModule.getFile()) and 
    // Exclude artificial or insignificant changes to focus on meaningful code modifications
    not artificialChange(revision)
  |
    deletionCount
  )
select sourceModule, totalDeletedLines order by totalDeletedLines desc