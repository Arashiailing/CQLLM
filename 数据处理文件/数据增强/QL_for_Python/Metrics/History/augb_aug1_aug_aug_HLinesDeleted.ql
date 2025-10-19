/**
 * @name Deleted lines per file
 * @description Measures the total number of lines deleted from each file throughout the 
 *              entire version control history. This metric helps identify files that have
 *              experienced substantial refactoring or feature removal, which may indicate
 *              architectural evolution or elimination of deprecated functionality.
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
  // Ensure the module has valid code metrics before analysis
  targetFile.getMetrics().getNumberOfLinesOfCode() > 0 and
  // Compute the total lines removed from this file across all commits
  cumulativeDeletions = sum(Commit commitRecord, int linesRemoved |
    // Obtain deletion count for this specific file in each commit
    linesRemoved = commitRecord.getRecentDeletionsForFile(targetFile.getFile()) and 
    // Filter out commits that are artificial or insignificant
    not artificialChange(commitRecord)
  |
    linesRemoved
  )
select targetFile, cumulativeDeletions order by cumulativeDeletions desc