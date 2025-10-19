/**
 * @name Number of co-committed files
 * @description Analyzes the average number of additional files modified alongside a given file in each commit
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Core computation: Calculates total files modified in a specific commit
int getCommitModificationCount(Commit commitRecord) { 
    result = count(commitRecord.getAnAffectedFile()) 
}

// Primary analysis: Evaluates co-modification frequency across Python modules
from Module examinedModule
// Filter: Only process modules with available lines-of-code metrics
where exists(examinedModule.getMetrics().getNumberOfLinesOfCode())
select examinedModule,
  // Compute average count of co-modified files for this module
  avg(Commit commitRecord, int coModifiedCount |
    // Condition: Commit must affect a file from current module
    commitRecord.getAnAffectedFile() = examinedModule.getFile() and 
    // Calculate additional files modified in same commit
    coModifiedCount = getCommitModificationCount(commitRecord) - 1
  |
    coModifiedCount
  )