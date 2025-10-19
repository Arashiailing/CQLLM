/**
 * @name File-level code churn analysis
 * @description Quantifies the cumulative line modifications per file across the entire version control history.
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

// Query to fetch source modules and their corresponding total churn metrics
from Module fileModule, int cumulativeChurn
where
  // Validate that the module contains measurable code lines
  exists(fileModule.getMetrics().getNumberOfLinesOfCode()) and
  // Compute the total churn by aggregating changes from all relevant commits
  cumulativeChurn =
    sum(Commit commitRecord, int lineModificationCount |
      // Retrieve the line modification count for each file in the commit history, excluding artificial changes
      lineModificationCount = commitRecord.getRecentChurnForFile(fileModule.getFile()) and 
      not artificialChange(commitRecord)
    |
      // Accumulate all individual line modifications to get the total churn
      lineModificationCount
    )
// Select the module and its cumulative churn, sorted in descending order of churn
select fileModule, cumulativeChurn order by cumulativeChurn desc