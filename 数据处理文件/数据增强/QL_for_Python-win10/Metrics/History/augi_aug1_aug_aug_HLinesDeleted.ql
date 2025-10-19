/**
 * @name Deleted lines per file
 * @description Measures cumulative line deletions per file across all commits.
 *              Identifies files with substantial refactoring or feature removal,
 *              indicating architectural shifts or deprecated components.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

from Module codeModule, int aggregateDeletedLines
where
  // Ensure the module contains measurable code content
  exists(codeModule.getMetrics().getNumberOfLinesOfCode()) and
  // Compute total lines removed from this module throughout version control history
  aggregateDeletedLines = sum(Commit changeSet, int linesRemoved |
    // For each commit, retrieve the count of deleted lines for this specific module
    linesRemoved = changeSet.getRecentDeletionsForFile(codeModule.getFile()) and 
    // Filter out artificial or trivial modifications to focus on significant code changes
    not artificialChange(changeSet)
  |
    linesRemoved
  )
select codeModule, aggregateDeletedLines order by aggregateDeletedLines desc