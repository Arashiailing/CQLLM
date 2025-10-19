/**
 * @name Number of co-committed files
 * @description Measures the average number of files that are modified together whenever a specific file is changed in a commit
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Main analysis: Evaluates co-modification patterns across different modules
from Module analyzedModule
// Filtering condition: Only process modules that have measurable lines of code
where exists(analyzedModule.getMetrics().getNumberOfLinesOfCode())
select analyzedModule,
  // Compute the average count of files modified alongside files in this module
  avg(Commit commitRecord, int coCommitCount |
    // Condition: The commitRecord includes a file from the analyzedModule
    commitRecord.getAnAffectedFile() = analyzedModule.getFile() and 
    // Calculate the number of additional files modified in the same commitRecord
    coCommitCount = count(commitRecord.getAnAffectedFile()) - 1
  |
    coCommitCount
  )