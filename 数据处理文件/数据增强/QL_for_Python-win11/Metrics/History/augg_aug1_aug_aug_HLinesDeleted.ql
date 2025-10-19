/**
 * @name Deleted lines per file
 * @description Measures total lines deleted per file across all commits.
 *              Identifies files experiencing major refactoring or feature removal,
 *              highlighting architectural shifts or deprecated components.
 * @kind treemap
 * @id py/historical-lines-deleted
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python
import external.VCS

from Module codeModule, int cumulativeDeletions
where
  // Ensure the module contains measurable code before analysis
  codeModule.getMetrics().getNumberOfLinesOfCode() > 0 and
  // Aggregate all line deletions from the module's commit history
  cumulativeDeletions = sum(Commit commitVersion, int linesRemoved |
    // Track lines removed from this module in each commit
    linesRemoved = commitVersion.getRecentDeletionsForFile(codeModule.getFile()) and
    // Filter out automated or trivial changes to focus on significant modifications
    not artificialChange(commitVersion)
  |
    linesRemoved
  )
select codeModule, cumulativeDeletions order by cumulativeDeletions desc