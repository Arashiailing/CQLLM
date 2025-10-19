/**
 * @name Count of recent contributors
 * @description Calculates the number of distinct contributors who have made recent modifications
 * @kind treemap
 * @id py/historical-number-of-recent-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

from Module targetModule
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  count(Author contributor |
    exists(Commit revision |
      revision = contributor.getACommit() and
      targetModule.getFile() = revision.getAnAffectedFile() and
      revision.daysToNow() <= 180 and
      not artificialChange(revision)
    )
  )