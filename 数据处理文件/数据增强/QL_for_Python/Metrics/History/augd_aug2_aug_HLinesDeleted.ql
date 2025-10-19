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

// Analyze source code files and calculate cumulative deletion metrics across their entire version history
from Module sourceFile, int cumulativeDeletions
where
  // Calculate the sum of all deleted lines for each file across its commit history
  exists(int deletionCount |
    deletionCount = 
      sum(Commit versionCommit, int deletedLines |
        // Retrieve deletion metrics from commits that modified the file
        deletedLines = versionCommit.getRecentDeletionsForFile(sourceFile.getFile()) and
        // Filter out commits that represent non-functional changes (e.g., automated refactoring operations)
        not artificialChange(versionCommit)
      |
        deletedLines
      ) and
    cumulativeDeletions = deletionCount
  ) and
  // Verify that the file has valid code metrics available for analysis
  exists(sourceFile.getMetrics().getNumberOfLinesOfCode())
select sourceFile, cumulativeDeletions order by cumulativeDeletions desc