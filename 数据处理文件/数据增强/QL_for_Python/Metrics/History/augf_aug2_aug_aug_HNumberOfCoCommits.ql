/**
 * @name Co-committed Files Analysis
 * @description Calculates the average number of additional files modified alongside 
 *              a specific file in commits. This metric identifies files frequently 
 *              changed together, indicating potential dependencies or relationships.
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Primary analysis: Process modules with valid line count metrics
from Module targetModule
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  // Aggregate calculation: Compute mean co-modified files per module
  avg(Commit commitRecord, int concurrentChanges |
    // Identify commits affecting the target module and calculate co-change count
    commitRecord.getAnAffectedFile() = targetModule.getFile() and 
    concurrentChanges = (count(commitRecord.getAnAffectedFile()) - 1)
  |
    concurrentChanges
  )