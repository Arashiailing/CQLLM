/**
 * @name Recent contributors count per module
 * @description Counts distinct contributors who made changes in the last 180 days
 * @kind treemap
 * @id py/historical-number-of-recent-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Identify modules with measurable lines of code
from Module codeModule
where exists(codeModule.getMetrics().getNumberOfLinesOfCode())
select codeModule,
  count(Author recentContributor |
    // Find commits authored by this contributor that impacted the module
    exists(Commit moduleCommit |
      moduleCommit = recentContributor.getACommit() and
      // Verify the commit affected the module's file
      codeModule.getFile() = moduleCommit.getAnAffectedFile() and
      // Filter for recent commits (within 180 days)
      moduleCommit.daysToNow() <= 180 and
      // Exclude artificial or automated changes
      not artificialChange(moduleCommit)
    )
  )