/**
 * @name File Deletion Metrics
 * @description Generates a treemap visualization that illustrates the cumulative count of lines removed from each source file across the entire commit history of the project.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

// Locate source modules and compute their cumulative deletion metrics
from Module sourceModule, int deletedLinesCount
where
  // Ensure the module has quantifiable code content
  exists(sourceModule.getMetrics().getNumberOfLinesOfCode()) and
  // Calculate the total number of lines eliminated in all relevant commits
  deletedLinesCount = sum(
    Commit commitEntry, int linesRemoved |
      // Retrieve the count of lines removed in each commit that modifies this module
      linesRemoved = commitEntry.getRecentDeletionsForFile(sourceModule.getFile()) and
      // Filter out synthetic commits that do not represent genuine development activities
      not artificialChange(commitEntry)
    |
      linesRemoved
  )
select sourceModule, deletedLinesCount order by deletedLinesCount desc