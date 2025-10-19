/**
 * @name Added lines per file
 * @description Number of added lines per file, across the revision history in the database.
 * @kind treemap
 * @id py/historical-lines-added
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

from Module targetModule, int totalAddedLines
where
  // Calculate cumulative line additions across all commits for each module
  totalAddedLines =
    sum(Commit versionCommit, int addedLineCount |
      // Retrieve line additions from the most recent commit for the module's file
      addedLineCount = versionCommit.getRecentAdditionsForFile(targetModule.getFile()) and
      // Exclude commits that are artificial or automated changes
      not artificialChange(versionCommit)
    |
      // Aggregate the line counts across all qualifying commits
      addedLineCount
    ) and
  // Verify that the module has valid lines of code metrics available
  exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule, totalAddedLines order by totalAddedLines desc