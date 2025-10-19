/**
 * @name Recent contributors count per module
 * @description Quantifies the number of distinct authors who have contributed to each module within the past 180 days
 * @kind treemap
 * @id py/historical-number-of-recent-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Identify modules with measurable lines of code
from Module targetModule
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  count(Author codeAuthor |
    // Determine if this author has recent, legitimate commits affecting the module
    exists(Commit versionCommit |
      // Verify the commit is associated with the author
      versionCommit = codeAuthor.getACommit() and
      // Confirm the commit modified a file in the target module
      targetModule.getFile() = versionCommit.getAnAffectedFile() and
      // Ensure the commit occurred within the last 180 days
      versionCommit.daysToNow() <= 180 and
      // Exclude artificial or automated changes
      not artificialChange(versionCommit)
    )
  )