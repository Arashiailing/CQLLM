/**
 * @name Number of commits
 * @description Provides a count of all repository commits, excluding artificial changes
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// Import Python language support for the analysis
import python
// Import Version Control System (VCS) libraries to access commit history data
import external.VCS

// Data source: retrieve all commit records from the repository
from Commit revision
// Filtering: exclude any commits that represent artificial or non-user changes
where not artificialChange(revision)
// Output: for each valid commit, return its revision name and a count of 1 for aggregation
select revision.getRevisionName(), 1