/**
 * @name Deleted lines per file
 * @description Computes the total number of lines deleted from each file across the repository's complete commit history.
 *              This metric identifies files experiencing substantial code refactoring or feature elimination, providing
 *              insights into codebase evolution and maintenance patterns.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

from Module targetFile, int aggregateDeletedCount
where
  // Filter for modules with valid line count metrics to ensure analytical significance
  exists(targetFile.getMetrics().getNumberOfLinesOfCode()) and
  // Aggregate deletion counts by summing lines removed in each relevant commit
  aggregateDeletedCount = sum(Commit commit, int commitDeletedLines |
    // Extract deletion count for the target file in each commit
    commitDeletedLines = commit.getRecentDeletionsForFile(targetFile.getFile()) and 
    // Exclude artificial or automated changes to focus on meaningful modifications
    not artificialChange(commit)
  |
    commitDeletedLines
  )
select targetFile, aggregateDeletedCount order by aggregateDeletedCount desc