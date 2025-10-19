/**
 * @name File Deletion Metrics
 * @description Displays a treemap visualization showing the total number of lines deleted from each source file throughout the project's commit history.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

// Identify code modules and calculate their accumulated deletion statistics
from Module codeModule, int totalDeletions
where
  // Verify that the module contains measurable code content
  exists(codeModule.getMetrics().getNumberOfLinesOfCode()) and
  // Compute the aggregate count of lines removed across all commits
  totalDeletions = 
    sum(Commit commitRecord, int deletedLines |
      // Obtain the number of lines deleted in each commit affecting this module
      deletedLines = commitRecord.getRecentDeletionsForFile(codeModule.getFile()) and
      // Exclude artificial commits that don't represent actual development changes
      not artificialChange(commitRecord)
    |
      deletedLines
    )
select codeModule, totalDeletions order by totalDeletions desc