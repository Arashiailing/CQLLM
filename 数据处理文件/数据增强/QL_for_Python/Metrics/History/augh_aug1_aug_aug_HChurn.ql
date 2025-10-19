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
from Module sourceModule, int totalChurn
where
  // Calculate the sum of all line modifications across the module's file history
  totalChurn = sum(
    Commit versionCommit, int modificationAmount |
      // Obtain the change metrics for each commit, filtering out artificial changes
      modificationAmount = versionCommit.getRecentChurnForFile(sourceModule.getFile()) and
      not artificialChange(versionCommit)
    |
      // Sum up the individual line modifications
      modificationAmount
  ) and
  // Ensure that the module has a valid lines-of-code measurement
  exists(sourceModule.getMetrics().getNumberOfLinesOfCode())
// Return the modules sorted by total churn in descending order
select sourceModule, totalChurn order by totalChurn desc