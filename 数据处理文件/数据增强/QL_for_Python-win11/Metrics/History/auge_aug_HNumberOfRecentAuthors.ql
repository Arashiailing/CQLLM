/**
 * @name Recent contributors count per module
 * @description Calculates the number of unique contributors who modified code in the past 180 days
 * @kind treemap
 * @id py/historical-number-of-recent-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Filter for modules containing measurable code
from Module targetModule
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  count(Author codeAuthor |
    // Identify commits from this author that impacted the module
    exists(Commit versionCommit |
      versionCommit = codeAuthor.getACommit() and
      targetModule.getFile() = versionCommit.getAnAffectedFile() and
      versionCommit.daysToNow() <= 180 and
      not artificialChange(versionCommit)
    )
  )