/**
 * @name Cumulative deleted lines per source file
 * @description Calculates the total number of lines removed from each source file across the entire commit history.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

// Identify source modules and their corresponding accumulated line deletion metrics
from Module sourceModule, int deletedLinesCount
where
  // Ensure the module has valid code metrics available for analysis
  exists(sourceModule.getMetrics().getNumberOfLinesOfCode()) and
  // Calculate the aggregate count of lines removed across all relevant commits
  deletedLinesCount = 
    sum(Commit commitEntry, int linesDeletedInCommit |
      // Retrieve the number of lines deleted in the latest commit affecting this file
      linesDeletedInCommit = commitEntry.getRecentDeletionsForFile(sourceModule.getFile()) and
      // Filter out commits that represent artificial or insignificant modifications
      not artificialChange(commitEntry)
    |
      linesDeletedInCommit
    )
select sourceModule, deletedLinesCount order by deletedLinesCount desc