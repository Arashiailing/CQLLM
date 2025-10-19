/**
 * @name Co-committed Files Analysis
 * @description Analyzes the average number of additional files modified alongside 
 *              a specific file in commit operations. This metric identifies files 
 *              that are frequently modified together, indicating potential code 
 *              coupling or hidden dependencies between components.
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Target modules with quantifiable code metrics for analysis
from Module targetModule
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  // Determine the average quantity of co-modified files for each target module
  avg(Commit commitEntry, int coModifiedFilesCount |
    // Identify commits that include changes to the target module's file
    commitEntry.getAnAffectedFile() = targetModule.getFile() and 
    // Compute the count of accompanying files (total files in commit minus the primary file)
    coModifiedFilesCount = count(commitEntry.getAnAffectedFile()) - 1
  |
    coModifiedFilesCount
  )