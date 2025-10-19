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
from Module sourceModule, int totalChurn
where
  // Ensure the module has a valid lines of code measurement
  exists(sourceModule.getMetrics().getNumberOfLinesOfCode()) and
  // Calculate the aggregate churn across all commits for the file
  totalChurn =
    sum(Commit versionCommit, int changedLines |
      // Extract the churn metric for each file in recent commits, filtering out synthetic changes
      changedLines = versionCommit.getRecentChurnForFile(sourceModule.getFile()) and 
      not artificialChange(versionCommit)
    |
      // Sum up all the individual line changes
      changedLines
    )
// Select the module and its total churn, ordered by highest churn first
select sourceModule, totalChurn order by totalChurn desc