/**
 * @name Deleted lines per file
 * @description Calculates the total number of lines deleted for each file throughout its revision history.
 *               This metric helps identify files that have undergone significant refactoring or removal of code.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

// Select file modules and their corresponding deletion counts
from Module fileModule, int totalDeletedLines
where
  // Calculate total deletions for each file across commit history
  totalDeletedLines = 
    sum(Commit commit, int deletedLines |
      // Get deletion count from most recent commit for the file
      deletedLines = commit.getRecentDeletionsForFile(fileModule.getFile()) and
      // Exclude artificial changes from the calculation
      not artificialChange(commit)
    |
      deletedLines
    ) and
  // Ensure the module has available code metrics
  exists(fileModule.getMetrics().getNumberOfLinesOfCode())
select fileModule, totalDeletedLines order by totalDeletedLines desc