/**
 * @name Co-committed files analysis
 * @description Computes the average count of files that are modified alongside each file
 *              in all commits that touch that file
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Main analysis query
from Module targetModule
// Filter to include only modules with available lines of code metrics
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  // Determine the average number of files co-committed with this module
  avg(Commit commitRecord, int coModifiedFiles |
    // Identify commits that modify this module's file
    commitRecord.getAnAffectedFile() = targetModule.getFile() and
    // Compute co-committed files (total affected files minus the module file itself)
    coModifiedFiles = count(commitRecord.getAnAffectedFile()) - 1
  |
    coModifiedFiles
  )