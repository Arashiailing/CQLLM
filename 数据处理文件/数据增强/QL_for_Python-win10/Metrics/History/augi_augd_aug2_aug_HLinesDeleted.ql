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

// Analyze Python modules and compute cumulative deletion metrics across their complete version history
from Module targetModule, int aggregatedDeletions
where
  // Validate that the module has measurable code metrics available for processing
  exists(targetModule.getMetrics().getNumberOfLinesOfCode()) and
  // Compute the aggregate count of deleted lines for each module throughout all commits
  exists(int deletionAggregate |
    deletionAggregate = 
      sum(Commit historyCommit, int removedLines |
        // Extract deletion statistics from commits that modified the target module
        removedLines = historyCommit.getRecentDeletionsForFile(targetModule.getFile()) and
        // Exclude commits representing artificial modifications (e.g., automated refactoring)
        not artificialChange(historyCommit)
      |
        removedLines
      ) and
    aggregatedDeletions = deletionAggregate
  )
select targetModule, aggregatedDeletions order by aggregatedDeletions desc