/**
 * @name Co-modified Files Analysis
 * @description Computes the mean count of extra files altered in commits 
 *              that involve modifications to a particular file. This measure helps 
 *              identify files that tend to be changed concurrently, suggesting 
 *              possible architectural relationships or code dependencies.
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

// Helper function that calculates the total number of files modified in a specific commit
int calculateFilesChangedInCommit(Commit commitEntry) { 
    result = count(commitEntry.getAnAffectedFile()) 
}

// Main analysis: process modules with available line count metrics
from Module selectedModule
where exists(selectedModule.getMetrics().getNumberOfLinesOfCode())
select selectedModule,
  // Calculate the average quantity of co-modified files per module
  avg(Commit commitEntry, int coChangeCount |
    // Filter commits that affect the module's file and calculate co-change metrics
    commitEntry.getAnAffectedFile() = selectedModule.getFile() and 
    coChangeCount = calculateFilesChangedInCommit(commitEntry) - 1
  |
    coChangeCount
  )