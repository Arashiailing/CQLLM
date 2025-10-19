/**
 * @name Co-committed Files Analysis
 * @description Measures the average number of files modified together with a target file
 *              across all commits. This metric reveals code coupling patterns and
 *              implicit dependencies by identifying frequently co-changed files.
 * @kind treemap
 * @id py/historical-co-commit-frequency
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Identify modules with measurable codebase characteristics
from Module focalModule
where exists(focalModule.getMetrics().getNumberOfLinesOfCode())
select focalModule,
  // Compute average co-modified files per commit for the target module
  avg(Commit commitInScope, int coChangedFileCount |
    // Step 1: Find commits touching the target module's file
    commitInScope.getAnAffectedFile() = focalModule.getFile() 
    // Step 2: Calculate co-modified files (total files - target file)
    and coChangedFileCount = count(commitInScope.getAnAffectedFile()) - 1
  |
    coChangedFileCount
  )