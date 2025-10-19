/**
 * @name Recent Module Contributors Analysis
 * @description Counts distinct contributors who modified each module within the last 180 days
 * @kind treemap
 * @id py/historical-number-of-recent-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Find modules that contain measurable code
from Module analyzedModule
where exists(analyzedModule.getMetrics().getNumberOfLinesOfCode())
select analyzedModule,
  count(Author moduleAuthor |
    // Verify if the author has recent commits affecting this module
    exists(Commit recentCommit |
      recentCommit = moduleAuthor.getACommit() and
      recentCommit.daysToNow() <= 180 and
      not artificialChange(recentCommit) and
      analyzedModule.getFile() = recentCommit.getAnAffectedFile()
    )
  )