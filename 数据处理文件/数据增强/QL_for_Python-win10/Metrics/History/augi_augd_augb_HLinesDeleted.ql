/**
 * @name Deleted lines per file
 * @description Computes the aggregate count of lines removed from each file across
 *              the entire version control history available in the database.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

from Module targetFile, int totalLinesRemoved
where
  // Ensure the module has valid code metrics information
  exists(targetFile.getMetrics().getNumberOfLinesOfCode()) and
  // Compute the total number of lines deleted for each module over all commits
  totalLinesRemoved = sum(Commit versionCommit, int removedCount |
    // For each commit, obtain the count of lines deleted from the file
    removedCount = versionCommit.getRecentDeletionsForFile(targetFile.getFile()) and 
    // Filter out artificial or automated commits from the calculation
    not artificialChange(versionCommit)
  |
    removedCount
  )
select targetFile, totalLinesRemoved order by totalLinesRemoved desc