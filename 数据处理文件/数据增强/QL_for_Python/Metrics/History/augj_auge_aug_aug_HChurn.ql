/**
 * @name File-level code churn analysis
 * @description Measures the total number of line changes for each file throughout the entire version control history.
 * @kind treemap
 * @id py/historical-churn
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

// Import necessary modules for Python code analysis and version control tracking
import python
import external.VCS

// Main query to retrieve source files and their associated churn metrics
from Module sourceFile, int totalCodeChurn
where
  // First condition: ensure the file has measurable code
  exists(sourceFile.getMetrics().getNumberOfLinesOfCode())
  and
  // Second condition: calculate the cumulative code churn
  (
    totalCodeChurn =
      sum(Commit versionCommit, int modifiedLines |
        // Get the line modifications for this file in each commit
        modifiedLines = versionCommit.getRecentChurnForFile(sourceFile.getFile()) 
        and
        // Exclude artificial changes from the analysis
        not artificialChange(versionCommit)
      |
        // Aggregate all line modifications
        modifiedLines
      )
  )
// Output results ordered by highest churn first
select sourceFile, totalCodeChurn order by totalCodeChurn desc