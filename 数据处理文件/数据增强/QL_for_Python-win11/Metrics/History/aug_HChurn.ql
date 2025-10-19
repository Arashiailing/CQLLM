/**
 * @name File-level code churn analysis
 * @description Calculates the total number of modified lines for each file throughout the version control history.
 * @kind treemap
 * @id py/historical-churn
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

// Import the Python language module for code analysis
import python
// Import the external Version Control System (VCS) module for commit history
import external.VCS

// Query to retrieve data from Module objects and corresponding modification counts
from Module moduleObj, int modificationCount
where
  // Compute the total number of changed lines for each file, stored in modificationCount
  modificationCount =
    sum(Commit commit, int linesChanged |
      // Retrieve the churn metric for the file in recent commits, excluding artificial changes
      linesChanged = commit.getRecentChurnForFile(moduleObj.getFile()) and 
      not artificialChange(commit)
    |
      // Aggregate the total number of changed lines
      linesChanged
    ) and
  // Verify that the module has a valid lines of code metric
  exists(moduleObj.getMetrics().getNumberOfLinesOfCode())
select moduleObj, modificationCount order by modificationCount desc
// Select the module and its modification count, sorted in descending order of churn