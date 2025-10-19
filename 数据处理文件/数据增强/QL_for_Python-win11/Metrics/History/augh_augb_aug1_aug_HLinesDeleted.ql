/**
 * @name Deleted lines per file
 * @description Computes the cumulative count of lines removed from each source file throughout the entire commit history of the repository.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

// Identify source modules and compute their aggregate line deletion statistics
from Module srcFile, int deletedLines
where
  // Verify that the source module contains measurable code content prior to analysis
  exists(srcFile.getMetrics().getNumberOfLinesOfCode()) and
  // Compute the aggregate lines deleted across all authentic commits for this module
  deletedLines = sum(Commit commit, int linesRemoved |
      // Obtain the count of lines eliminated in each commit that impacts this module
      linesRemoved = commit.getRecentDeletionsForFile(srcFile.getFile()) and
      // Exclude commits that are artificial or not representative of genuine modifications
      not artificialChange(commit)
    | 
      linesRemoved
    )
select srcFile, deletedLines order by deletedLines desc