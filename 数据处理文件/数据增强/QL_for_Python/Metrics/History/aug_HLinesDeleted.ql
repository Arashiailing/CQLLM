/**
 * @name Deleted lines per file
 * @description Number of deleted lines per file, across the revision history in the database.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

// Select file modules and their corresponding deletion counts
from Module sourceFile, int deletionCount
where
  // Calculate total deletions for each file across commit history
  deletionCount = 
    sum(Commit revision, int linesDeleted |
      // Retrieve deletion count from most recent commit for the file
      linesDeleted = revision.getRecentDeletionsForFile(sourceFile.getFile()) and
      // Filter out artificial changes
      not artificialChange(revision)
    |
      linesDeleted
    ) and
  // Verify that code metrics are available for this module
  exists(sourceFile.getMetrics().getNumberOfLinesOfCode())
select sourceFile, deletionCount order by deletionCount desc