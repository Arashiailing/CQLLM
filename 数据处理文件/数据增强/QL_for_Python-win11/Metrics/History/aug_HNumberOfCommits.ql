/**
 * @name Number of commits
 * @description Counts the number of commits in the repository, excluding artificial changes
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// Import Python language support for analysis
import python
// Import Version Control System (VCS) libraries to access commit history
import external.VCS

// Define the source of data: all commit records
from Commit commitEntry
// Filter condition: exclude commits that represent artificial changes
where not artificialChange(commitEntry)
// Selection: retrieve the revision name of each commit and count it as 1 for aggregation
select commitEntry.getRevisionName(), 1