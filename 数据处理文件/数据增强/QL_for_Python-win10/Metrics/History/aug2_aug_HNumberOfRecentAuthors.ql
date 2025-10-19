/**
 * @name Module Recent Contributors Analysis
 * @description Analyzes and counts the number of distinct contributors who have made changes to each module within the past 180 days
 * @kind treemap
 * @id py/historical-number-of-recent-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Identify modules with measurable code lines
from Module targetModule
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  count(Author codeAuthor |
    // Check for recent commits by this author affecting the module
    exists(Commit versionCommit |
      versionCommit = codeAuthor.getACommit() and
      targetModule.getFile() = versionCommit.getAnAffectedFile() and
      versionCommit.daysToNow() <= 180 and
      not artificialChange(versionCommit)
    )
  )