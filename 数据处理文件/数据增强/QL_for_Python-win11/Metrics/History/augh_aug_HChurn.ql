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

// Query to retrieve data from file modules and their corresponding total modification counts
from Module fileModule, int totalChurnCount
where
  // Calculate the aggregate number of changed lines across all commits for each file
  totalChurnCount =
    sum(Commit commitRecord, int modifiedLines |
      // Obtain the churn metric for the file in recent commits, filtering out artificial changes
      modifiedLines = commitRecord.getRecentChurnForFile(fileModule.getFile()) and 
      not artificialChange(commitRecord)
    |
      // Sum up all the modified lines to get the total churn count
      modifiedLines
    ) and
  // Ensure the module has a valid lines of code metric for analysis
  exists(fileModule.getMetrics().getNumberOfLinesOfCode())
// Select the file module and its total churn count, sorted by highest churn first
select fileModule, totalChurnCount order by totalChurnCount desc