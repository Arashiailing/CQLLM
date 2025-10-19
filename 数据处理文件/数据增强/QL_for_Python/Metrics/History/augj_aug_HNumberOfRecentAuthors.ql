/**
 * @name Recent contributors count per module
 * @description This query calculates the number of distinct contributors who have made 
 *              changes to each Python module within the last 180 days. It helps identify
 *              modules with high contributor activity, which may indicate areas of frequent
 *              updates or potential maintenance burden.
 * @kind treemap
 * @id py/historical-number-of-recent-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Select each module that has lines of code metrics
from Module targetModule
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  count(Author codeAuthor |
    // Check if the author has made valid commits to the module in the last 180 days
    exists(Commit versionCommit |
      versionCommit = codeAuthor.getACommit() and
      targetModule.getFile() = versionCommit.getAnAffectedFile() and
      versionCommit.daysToNow() <= 180 and
      not artificialChange(versionCommit)
    )
  )