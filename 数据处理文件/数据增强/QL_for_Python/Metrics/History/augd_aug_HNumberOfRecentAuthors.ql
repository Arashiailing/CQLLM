/**
 * @name Recent contributors count per module
 * @description This query calculates the number of distinct contributors who have made changes 
 *              to each code module within the last 180 days, excluding artificial changes.
 * @kind treemap
 * @id py/historical-number-of-recent-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Select each code module that has lines of code metrics available
from Module codeModule
where exists(codeModule.getMetrics().getNumberOfLinesOfCode())
select codeModule,
  count(Author moduleAuthor |
    // Check if this author has commits affecting the module within the time frame
    exists(Commit moduleCommit |
      moduleCommit = moduleAuthor.getACommit() and
      codeModule.getFile() = moduleCommit.getAnAffectedFile() and
      moduleCommit.daysToNow() <= 180 and
      not artificialChange(moduleCommit)
    )
  )