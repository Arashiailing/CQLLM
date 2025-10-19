/**
 * @name Deleted lines per file
 * @description Calculates the total number of lines deleted for each Python file 
 *              throughout the entire revision history stored in the database.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

// Query to find Python modules and their accumulated deletion metrics
from Module pythonModule, int deletedLinesCount
where
  // Verify that the module contains measurable code before analysis
  exists(pythonModule.getMetrics().getNumberOfLinesOfCode()) and
  // Compute the total lines deleted across all meaningful commits
  deletedLinesCount = sum(
    // Subquery to gather deletion data from each relevant commit
    Commit commit, int linesDeleted |
      // Determine how many lines were removed in this specific commit
      linesDeleted = commit.getRecentDeletionsForFile(pythonModule.getFile()) and
      // Filter out commits that are artificial or not significant
      not artificialChange(commit)
    |
      // Aggregate the deletion counts
      linesDeleted
  )
// Output results ordered by deletion count in descending order
select pythonModule, deletedLinesCount order by deletedLinesCount desc