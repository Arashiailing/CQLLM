/**
 * @name Deleted lines per file
 * @description Tracks the cumulative count of lines removed from each file throughout the commit history.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

// Select code modules and their accumulated line removal counts
from Module codeModule, int linesRemoved
where
  // Verify the module has available code metrics before processing
  exists(codeModule.getMetrics().getNumberOfLinesOfCode()) and
  // Compute the total lines removed across all relevant commits
  linesRemoved = 
    sum(Commit commitRecord, int deletedLines |
      // Obtain the number of lines deleted in the most recent commit for this file
      deletedLines = commitRecord.getRecentDeletionsForFile(codeModule.getFile()) and
      // Exclude commits that represent artificial or non-meaningful changes
      not artificialChange(commitRecord)
    |
      deletedLines
    )
select codeModule, linesRemoved order by linesRemoved desc