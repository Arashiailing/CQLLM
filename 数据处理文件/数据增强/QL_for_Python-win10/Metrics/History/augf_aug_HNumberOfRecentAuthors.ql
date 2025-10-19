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
from Module moduleEntity
where exists(moduleEntity.getMetrics().getNumberOfLinesOfCode())
select moduleEntity,
  count(Author codeAuthor |
    // Find commits by this author that affected the module
    exists(Commit commitRecord |
      commitRecord = codeAuthor.getACommit() and
      moduleEntity.getFile() = commitRecord.getAnAffectedFile() and
      commitRecord.daysToNow() <= 180 and
      not artificialChange(commitRecord)
    )
  )