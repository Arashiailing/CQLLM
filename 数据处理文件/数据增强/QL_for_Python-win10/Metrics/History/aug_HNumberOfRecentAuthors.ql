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

// Select each module that has lines of code metrics
from Module moduleObj
where exists(moduleObj.getMetrics().getNumberOfLinesOfCode())
select moduleObj,
  count(Author contributor |
    // Find commits by this contributor that affected the module
    exists(Commit commitEntry |
      commitEntry = contributor.getACommit() and
      moduleObj.getFile() = commitEntry.getAnAffectedFile() and
      commitEntry.daysToNow() <= 180 and
      not artificialChange(commitEntry)
    )
  )