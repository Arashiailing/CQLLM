/**
 * @name Churned lines per file
 * @description Number of churned lines per file, across the revision history in the database.
 * @kind treemap
 * @id py/historical-churn
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

// Import the Python language module for code analysis
import python
// Import the external Version Control System (VCS) module for change tracking
import external.VCS

// Analyze each source module and calculate its total churn
from Module sourceModule, int totalChurn
where
  // Calculate the total churn for each module by summing up changes across all commits
  totalChurn =
    sum(Commit revision, int changeCount |
      // Get the churn for the current file in this commit, excluding artificial changes
      changeCount = revision.getRecentChurnForFile(sourceModule.getFile()) and
      not artificialChange(revision)
    |
      changeCount  // Accumulate the change count
    ) and
  // Only consider modules that have measurable lines of code
  exists(sourceModule.getMetrics().getNumberOfLinesOfCode())
// Select the module and its total churn, ordered by churn in descending order
select sourceModule, totalChurn order by totalChurn desc