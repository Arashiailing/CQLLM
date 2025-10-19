/**
 * @name File-level code churn analysis
 * @description Measures the cumulative line modifications across each file's entire version control history.
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
from Module sourceFile, int totalChurn
where
  // Calculate the total number of changed lines for each file, stored in totalChurn
  totalChurn =
    sum(Commit revision, int changedLines |
      // Obtain the churn metric for the file in recent commits, excluding artificial changes
      changedLines = revision.getRecentChurnForFile(sourceFile.getFile()) and 
      not artificialChange(revision)
    |
      // Sum up all the changed lines
      changedLines
    ) and
  // Ensure the module has a valid lines of code metric
  exists(sourceFile.getMetrics().getNumberOfLinesOfCode())
select sourceFile, totalChurn order by totalChurn desc
// Output the module and its total churn, sorted by highest churn first