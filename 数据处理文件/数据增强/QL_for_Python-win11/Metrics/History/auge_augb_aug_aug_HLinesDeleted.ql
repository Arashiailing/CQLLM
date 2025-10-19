/**
 * @name File Deletion Analysis
 * @description Computes the total number of lines deleted from each file across the repository's complete commit history.
 *              This metric identifies files that have experienced substantial code refactoring or feature elimination.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

from Module fileModule, int cumulativeDeletedLines
where
  // Verify that the module contains valid code metrics for accurate analysis
  exists(fileModule.getMetrics().getNumberOfLinesOfCode()) and
  // Compute the cumulative count of lines removed from this file across all commits
  cumulativeDeletedLines = sum(Commit revision, int linesRemovedInRevision |
    // For each commit, determine the number of lines deleted from this file, excluding trivial or automated changes
    linesRemovedInRevision = revision.getRecentDeletionsForFile(fileModule.getFile()) and 
    not artificialChange(revision)
  |
    linesRemovedInRevision
  )
select fileModule, cumulativeDeletedLines order by cumulativeDeletedLines desc