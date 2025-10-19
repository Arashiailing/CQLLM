/**
 * @name Lines Deleted Per Source File
 * @description Computes the cumulative count of lines removed from each file across all commits in its history.
 *               This metric identifies files that have experienced substantial code refactoring or elimination.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

// Query for source modules and their accumulated deletion metrics
from Module sourceFile, int cumulativeDeletions
where
  // Compute the total deletions for each file over its commit history
  cumulativeDeletions = 
    sum(Commit changeSet, int linesRemoved |
      // Obtain the deletion count from the latest commit affecting the file
      linesRemoved = changeSet.getRecentDeletionsForFile(sourceFile.getFile()) and
      // Filter out artificial commits to avoid skewing the metrics
      not artificialChange(changeSet)
    |
      linesRemoved
    ) and
  // Verify that the module has accessible code metrics data
  exists(sourceFile.getMetrics().getNumberOfLinesOfCode())
select sourceFile, cumulativeDeletions order by cumulativeDeletions desc