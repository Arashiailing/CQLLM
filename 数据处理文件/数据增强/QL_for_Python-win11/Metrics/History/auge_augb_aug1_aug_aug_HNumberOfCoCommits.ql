/**
 * @name Co-committed Files Analysis
 * @description Measures the average quantity of extra files modified in commits 
 *              that involve changes to a particular file. This metric helps detect 
 *              files that are often changed concurrently, suggesting possible 
 *              code coupling or implicit dependencies.
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Focus on modules that have measurable code metrics
from Module analyzedModule
where exists(analyzedModule.getMetrics().getNumberOfLinesOfCode())
select analyzedModule,
  // Compute the average count of co-committed files for each analyzed module
  avg(Commit commitRecord, int additionalFilesCount |
    // For each commit that affects the analyzed module's file
    commitRecord.getAnAffectedFile() = analyzedModule.getFile() and 
    // Calculate the number of additional files (total files in commit minus the target file)
    additionalFilesCount = count(commitRecord.getAnAffectedFile()) - 1
  |
    additionalFilesCount
  )