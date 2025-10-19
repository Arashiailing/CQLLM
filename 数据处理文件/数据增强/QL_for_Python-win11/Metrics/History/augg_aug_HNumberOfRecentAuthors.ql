/**
 * @name Recent contributors count per module
 * @description Analyzes and counts unique contributors who have made code changes
 *              to each module within the past 180 days, excluding artificial changes
 * @kind treemap
 * @id py/historical-number-of-recent-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Focus on modules that contain actual code (have lines of code metrics)
from Module targetModule
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  count(Author codeAuthor |
    // Identify commits made by this author that impacted the target module
    exists(Commit versionCommit |
      versionCommit = codeAuthor.getACommit() and
      targetModule.getFile() = versionCommit.getAnAffectedFile() and
      versionCommit.daysToNow() <= 180 and
      not artificialChange(versionCommit)
    )
  )