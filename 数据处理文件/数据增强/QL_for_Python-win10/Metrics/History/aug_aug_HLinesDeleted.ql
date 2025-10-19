/**
 * @name Deleted lines per file
 * @description Calculates the total number of lines deleted from each file across all commits in the repository's history.
 *              This metric is useful for identifying files that have experienced substantial refactoring or feature elimination.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

from Module moduleFile, int cumulativeDeletions
where
  // Compute the sum of all lines deleted across the commit history for this module
  cumulativeDeletions = sum(Commit commit, int linesDeletedInCommit |
    // For each commit, get the number of lines deleted from this file, excluding automated or trivial changes
    linesDeletedInCommit = commit.getRecentDeletionsForFile(moduleFile.getFile()) and 
    not artificialChange(commit)
  |
    linesDeletedInCommit
  ) and
  // Ensure the module has valid metrics to guarantee meaningful analysis results
  exists(moduleFile.getMetrics().getNumberOfLinesOfCode())
select moduleFile, cumulativeDeletions order by cumulativeDeletions desc