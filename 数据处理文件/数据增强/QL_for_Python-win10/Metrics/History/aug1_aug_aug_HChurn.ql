/**
 * @name File-level code churn analysis
 * @description Quantifies the cumulative line modifications per file across the entire version control history.
 * @kind treemap
 * @id py/historical-churn
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

// Import Python language module for code analysis
import python
// Import version control system (VCS) module for commit history analysis
import external.VCS

// Query to retrieve Python modules and their cumulative code change metrics
from Module pyModule, int cumulativeChurn
where
  // Verify module has valid lines-of-code measurement
  exists(pyModule.getMetrics().getNumberOfLinesOfCode()) and
  // Calculate total churn across all commits for the module's file
  cumulativeChurn = sum(
    Commit commit, int churnValue |
      // Fetch churn metrics for each commit, excluding artificial changes
      churnValue = commit.getRecentChurnForFile(pyModule.getFile()) and
      not artificialChange(commit)
    |
      // Aggregate individual line changes into total
      churnValue
  )
// Select modules ordered by highest cumulative churn first
select pyModule, cumulativeChurn order by cumulativeChurn desc