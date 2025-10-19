/**
 * @name File Deletion Analysis
 * @description Quantifies the total number of lines deleted per file throughout the entire commit history stored in the database.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

// Analyze each code module to determine cumulative line deletion metrics
from Module codeModule, int totalLinesRemoved
where
  // Ensure the module has measurable code metrics available
  exists(codeModule.getMetrics().getNumberOfLinesOfCode()) and
  // Calculate the aggregate of deleted lines across all relevant commits
  totalLinesRemoved = 
    sum(Commit commit, int deletedLines |
      // Extract deletion statistics from commits that modified this module
      deletedLines = commit.getRecentDeletionsForFile(codeModule.getFile()) and
      // Exclude commits representing artificial or automated changes
      not artificialChange(commit)
    |
      deletedLines
    )
select codeModule, totalLinesRemoved order by totalLinesRemoved desc