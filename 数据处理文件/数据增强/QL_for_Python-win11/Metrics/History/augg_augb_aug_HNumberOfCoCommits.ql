/**
 * @name Number of co-committed files
 * @description Measures the average quantity of additional files that are modified together with a target file within the same commit
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Primary analysis: Evaluates patterns of file co-modification across various modules
from Module targetModule
// Filtering condition: Only consider modules that have available lines of code metrics
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  // Calculate the average number of files co-committed with this module's files
  avg(Commit commitEvent, int coModifiedFileCount |
    // Condition: The commit must include at least one file from the current module
    commitEvent.getAnAffectedFile() = targetModule.getFile() and 
    // Compute the count of other files modified in the same commit
    coModifiedFileCount = (count(commitEvent.getAnAffectedFile()) - 1)
  |
    coModifiedFileCount
  )