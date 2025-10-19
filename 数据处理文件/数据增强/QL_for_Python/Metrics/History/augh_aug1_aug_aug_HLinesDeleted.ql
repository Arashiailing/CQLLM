/**
 * @name Deleted lines per file
 * @description Measures the total number of lines removed from each file throughout 
 *              the entire version control history. This metric reveals files that 
 *              experienced substantial code removal, which may indicate major refactoring 
 *              efforts, feature deprecation, or architectural shifts.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

from Module targetFile, int cumulativeDeletions
where
  // Ensure the file has valid code metrics before analysis
  exists(targetFile.getMetrics().getNumberOfLinesOfCode()) and
  // Compute the total lines removed across all commits for this file
  cumulativeDeletions = sum(Commit commitRecord, int linesRemoved |
    // For each commit, get the number of lines deleted from this specific file
    linesRemoved = commitRecord.getRecentDeletionsForFile(targetFile.getFile())
  |
    linesRemoved
  ) and
  // Filter out commits that represent artificial or insignificant modifications
  forall(Commit commitRecord, int linesRemoved |
    linesRemoved = commitRecord.getRecentDeletionsForFile(targetFile.getFile())
  |
    not artificialChange(commitRecord)
  )
select targetFile, cumulativeDeletions order by cumulativeDeletions desc