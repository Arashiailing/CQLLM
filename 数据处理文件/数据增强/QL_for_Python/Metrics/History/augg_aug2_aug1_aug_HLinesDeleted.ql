/**
 * @name File Deletion Metrics
 * @description Visualizes the total count of lines deleted from each source file throughout the project's version control history.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

// Calculate and retrieve source files with their total deletion metrics
from Module codeModule, int totalDeletions
where
  // Ensure the file has measurable code content before analysis
  exists(codeModule.getMetrics().getNumberOfLinesOfCode()) and
  // Aggregate the total lines deleted across all relevant commits
  totalDeletions = 
    sum(Commit historyCommit, int deletedLines |
      // Extract the count of lines deleted in the latest commit affecting this file
      deletedLines = historyCommit.getRecentDeletionsForFile(codeModule.getFile()) and
      // Filter out commits that are synthetic or not representative of actual development
      not artificialChange(historyCommit)
    |
      deletedLines
    )
select codeModule, totalDeletions order by totalDeletions desc