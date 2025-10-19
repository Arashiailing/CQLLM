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

// Calculate cumulative deletion metrics for each source code module
from Module sourceFile, int cumulativeDeletions
where
  // Compute total lines deleted across all commits for each file
  cumulativeDeletions = 
    sum(Commit revision, int linesRemoved |
      // Obtain deletion data from commits affecting the file
      linesRemoved = revision.getRecentDeletionsForFile(sourceFile.getFile()) and
      // Filter out commits that represent artificial changes (e.g., automated refactorings)
      not artificialChange(revision)
    |
      linesRemoved
    ) and
  // Verify that code metrics are available for this module
  exists(sourceFile.getMetrics().getNumberOfLinesOfCode())
select sourceFile, cumulativeDeletions order by cumulativeDeletions desc