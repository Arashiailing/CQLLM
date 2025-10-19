/**
 * @name Commit Count Analysis
 * @description Quantifies the total commits in the repository, excluding synthetic modifications
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// Import Python language module for analysis context
import python
// Import version control system utilities for commit tracking
import external.VCS

// Define query to analyze commit history
from Commit commitEntry
// Filter out artificial commits (e.g., automated refactoring, style adjustments)
where not artificialChange(commitEntry)
// Output each valid commit with its revision identifier and unit count
select commitEntry.getRevisionName(), 1