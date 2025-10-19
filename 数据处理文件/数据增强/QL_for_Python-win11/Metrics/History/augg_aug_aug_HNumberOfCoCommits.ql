/**
 * @name Co-committed Files Count
 * @description Calculates the average number of additional files modified in commits 
 *              that also affect a specific file. This metric helps identify files 
 *              that are frequently modified together, indicating potential 
 *              coupling or dependencies.
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Helper function that determines the total count of files affected in a specific commit
int countFilesInCommit(Commit c) { 
    result = count(c.getAnAffectedFile()) 
}

// Main analysis logic: evaluate modules with line count metrics for co-commit patterns
from Module analyzedModule
where exists(analyzedModule.getMetrics().getNumberOfLinesOfCode())
select analyzedModule,
  // Calculate the average number of co-committed files for each analyzed module
  avg(Commit commitAffectingModule, int coCommittedFiles |
    // Filter commits affecting the module's file and compute co-commit count
    commitAffectingModule.getAnAffectedFile() = analyzedModule.getFile() and 
    coCommittedFiles = countFilesInCommit(commitAffectingModule) - 1
  |
    coCommittedFiles
  )