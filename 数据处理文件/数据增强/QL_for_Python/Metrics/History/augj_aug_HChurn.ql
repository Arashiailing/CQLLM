/**
 * @name File-level code churn analysis
 * @description Quantifies cumulative line modifications per file across version control history
 * @kind treemap
 * @id py/historical-churn
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

// Import Python language module for code analysis
import python
// Import external VCS module for commit history access
import external.VCS

// Retrieve modules with valid code metrics and calculate total modifications
from Module fileModule, int totalChurn
where
  // Ensure module has measurable lines of code
  exists(fileModule.getMetrics().getNumberOfLinesOfCode()) and
  // Aggregate total changed lines across relevant commits
  totalChurn =
    sum(Commit commitRecord, int changedLines |
      // Fetch modification count excluding artificial changes
      changedLines = commitRecord.getRecentChurnForFile(fileModule.getFile()) and 
      not artificialChange(commitRecord)
    |
      changedLines  // Sum individual modification counts
    )
// Output modules ordered by modification volume (descending)
select fileModule, totalChurn order by totalChurn desc