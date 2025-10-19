/**
 * @name Co-committed Files Count
 * @description Measures the average count of additional files altered in commits 
 *              that also touch a particular file. This metric identifies files 
 *              often modified together, suggesting possible coupling or dependencies.
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Helper function that determines the total number of files affected in a given commit
int countFilesInCommit(Commit c) { 
    result = count(c.getAnAffectedFile()) 
}

// Main analysis: examine modules with line count metrics
from Module analyzedModule
where exists(analyzedModule.getMetrics().getNumberOfLinesOfCode())
select analyzedModule,
  // Compute the average number of co-committed files for each module
  avg(Commit commit, int coChangedFilesCount |
    // Focus on commits that affect the module's file and calculate co-commit count
    commit.getAnAffectedFile() = analyzedModule.getFile() and 
    coChangedFilesCount = countFilesInCommit(commit) - 1
  |
    coChangedFilesCount
  )