/**
 * @name Number of commits
 * @description This query calculates the total number of commits in the repository, 
 *              filtering out artificial commits to focus on genuine development activities.
 *              Each commit is counted as 1, and the revision identifier is used for tracking.
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// Import required CodeQL modules for Python code analysis and version control system tracking
import python
import external.VCS

// Define the commit instances to be analyzed from the version control system
from Commit commitRecord
// Apply filter to exclude artificial commits, ensuring only genuine development changes are counted
where not artificialChange(commitRecord)
// Output the revision identifier for each valid commit along with a count of 1 for aggregation
select commitRecord.getRevisionName(), 1