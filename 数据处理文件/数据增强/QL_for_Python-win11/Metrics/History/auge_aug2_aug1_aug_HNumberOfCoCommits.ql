/**
 * @name Number of co-committed files
 * @description Measures the average number of files modified together with files in a module
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Main analysis: Calculate co-modification patterns for modules with valid metrics
from Module moduleOfInterest
where exists(moduleOfInterest.getMetrics().getNumberOfLinesOfCode())
select moduleOfInterest,
  // Compute average co-modified files per commit affecting this module
  avg(Commit revision, int coModifiedCount |
    // Identify commits that modify files in the target module
    revision.getAnAffectedFile() = moduleOfInterest.getFile() and 
    // Calculate additional files modified in the same commit (excluding the module file)
    coModifiedCount = count(revision.getAnAffectedFile()) - 1
  |
    coModifiedCount
  )