/**
 * @name Number of commits
 * @description Calculates the total commit count within the repository, excluding artificial commits
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// Import necessary CodeQL modules for Python analysis and version control tracking
import python
import external.VCS

// Define the source of commits to analyze
from Commit commitEntry
// Filter out artificial commits to focus on genuine development activity
where not artificialChange(commitEntry)
// Output the revision identifier and a count of 1 for each valid commit
select commitEntry.getRevisionName(), 1