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
from Module codeFile, int cumulativeModifications
where
  // First condition: Verify that the file has measurable lines of code
  exists(codeFile.getMetrics().getNumberOfLinesOfCode()) and
  // Second condition: Compute the total churn by aggregating changes across all relevant commits
  cumulativeModifications =
    sum(Commit commitRecord, int modificationCount |
      // Retrieve the modification count for each file in recent commits
      modificationCount = commitRecord.getRecentChurnForFile(codeFile.getFile()) and 
      // Exclude artificial or automated changes from the analysis
      not artificialChange(commitRecord)
    |
      // Accumulate all individual line modifications
      modificationCount
    )
// Output the file and its total modification count, sorted by highest modification count first
select codeFile, cumulativeModifications order by cumulativeModifications desc