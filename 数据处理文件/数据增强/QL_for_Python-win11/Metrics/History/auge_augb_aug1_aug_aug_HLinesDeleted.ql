/**
 * @name Deleted lines per file
 * @description Calculates the cumulative count of lines removed from each file across
 *              the complete version control history. This analysis identifies files
 *              that have undergone significant refactoring or feature elimination,
 *              potentially indicating architectural changes or removal of deprecated code.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

from Module analyzedFile, int totalDeletedLines
where
  // Validate that the module contains meaningful code for analysis
  analyzedFile.getMetrics().getNumberOfLinesOfCode() > 0
  and
  // Aggregate the total lines deleted from this file throughout all commits
  totalDeletedLines = sum(Commit versionCommit, int deletedLinesCount |
    // Retrieve the number of lines deleted for this specific file in each commit
    deletedLinesCount = versionCommit.getRecentDeletionsForFile(analyzedFile.getFile())
    and
    // Exclude commits that are artificial or insignificant to the analysis
    not artificialChange(versionCommit)
  |
    deletedLinesCount
  )
select analyzedFile, totalDeletedLines order by totalDeletedLines desc