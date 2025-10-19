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

// Query to analyze source files and compute their total modification metrics
from Module sourceModule, int totalChurnCount
where
  // Precondition: Ensure the module contains measurable lines of code
  exists(sourceModule.getMetrics().getNumberOfLinesOfCode()) and
  // Calculate the total churn by aggregating changes across all relevant commits
  totalChurnCount = 
    sum(Commit versionCommit, int changeMetric |
      // Obtain the modification count for each file in recent commits
      changeMetric = versionCommit.getRecentChurnForFile(sourceModule.getFile()) and 
      // Filter out artificial or automated changes to focus on human-authored modifications
      not artificialChange(versionCommit)
    |
      // Aggregate all individual line modifications into a cumulative count
      changeMetric
    )
// Output the source module and its total churn count, sorted in descending order of modification frequency
select sourceModule, totalChurnCount order by totalChurnCount desc