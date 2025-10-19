/**
 * @name Number of commits
 * @description Counts the number of commits in the repository, excluding artificial changes
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// Import Python language support
import python
// Import version control system (VCS) functionality
import external.VCS

// Process each commit entry
from Commit commitEntry
// Filter out commits marked as artificial changes
where not artificialChange(commitEntry)
// Output revision identifier and unit count (1 per commit)
select commitEntry.getRevisionName(), 1