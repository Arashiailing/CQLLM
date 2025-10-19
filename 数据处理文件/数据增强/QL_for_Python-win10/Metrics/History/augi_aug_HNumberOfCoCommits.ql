/**
 * @name Number of co-committed files
 * @description The average number of other files that are touched whenever a file is affected by a commit
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Main analysis: Evaluates co-commit patterns for each module
from Module analysisModule
// Precondition: Only process modules that have available lines of code metrics
where exists(analysisModule.getMetrics().getNumberOfLinesOfCode())
select analysisModule,
  // Compute the average count of co-committed files per module
  avg(Commit commitEvent, int relatedFilesCount |
    // Identify commits affecting the current module's file
    commitEvent.getAnAffectedFile() = analysisModule.getFile() and 
    // Calculate the number of other files modified in the same commit
    relatedFilesCount = count(commitEvent.getAnAffectedFile()) - 1
  |
    relatedFilesCount
  )