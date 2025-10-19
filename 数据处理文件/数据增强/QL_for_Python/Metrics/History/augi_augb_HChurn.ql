/**
 * @name Churned lines per file
 * @description Quantifies cumulative line modifications per file throughout the revision history.
 * @kind treemap
 * @id py/historical-churn
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

// Import language-specific support for Python code analysis
import python
// Import version control system integration for historical data access
import external.VCS

// Analyze code modules and their associated modification statistics
from Module codeModule, int cumulativeChurn
where
  // Calculate aggregate line modifications across all relevant commits
  cumulativeChurn =
    sum(Commit commitRecord, int changeAmount |
      // Retrieve modification count for each file per commit, excluding automated changes
      changeAmount = commitRecord.getRecentChurnForFile(codeModule.getFile()) and 
      not artificialChange(commitRecord)
    |
      // Aggregate individual modification counts
      changeAmount
    ) and
  // Filter for modules with valid lines-of-code metrics
  exists(codeModule.getMetrics().getNumberOfLinesOfCode())
// Output modules ranked by total modification count in descending order
select codeModule, cumulativeChurn order by cumulativeChurn desc