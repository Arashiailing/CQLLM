/**
 * @name File-level code churn analysis
 * @description Measures the total number of line changes per file throughout the entire development history.
 * @kind treemap
 * @id py/historical-churn
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

// Import Python language module for source code analysis
import python
// Import version control system (VCS) module for tracking commit history
import external.VCS

// Query to identify Python modules and their aggregated code modification statistics
from Module targetFile, int cumulativeChanges
where
  // Ensure the module has valid lines of code measurement before calculating churn
  exists(targetFile.getMetrics().getNumberOfLinesOfCode()) and
  // Compute the cumulative line changes across all commits for the module
  cumulativeChanges = sum(
    Commit revision, int changeMetric |
      // Retrieve the change metrics for each commit, excluding artificial changes
      changeMetric = revision.getRecentChurnForFile(targetFile.getFile()) and
      not artificialChange(revision)
    |
      // Aggregate the individual line modification counts
      changeMetric
  )
// Return the modules sorted by total churn in descending order
select targetFile, cumulativeChanges order by cumulativeChanges desc