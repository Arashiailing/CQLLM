/**
 * @name Added lines per file
 * @description Calculates the total number of lines added to each file throughout its revision history.
 * @kind treemap
 * @id py/historical-lines-added
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

from Module fileModule, int totalAddedLines
where
  // Calculate the sum of added lines for each file across all commits
  totalAddedLines =
    sum(Commit versionCommit, int addedLines |
      // Retrieve the number of lines added in the most recent commit for the file
      // Exclude commits that are artificial or generated
      addedLines = versionCommit.getRecentAdditionsForFile(fileModule.getFile()) and 
      not artificialChange(versionCommit)
    |
      // Aggregate the count of added lines
      addedLines
    ) and
  // Ensure the module has valid lines of code metrics
  exists(fileModule.getMetrics().getNumberOfLinesOfCode())
select fileModule, totalAddedLines order by totalAddedLines desc