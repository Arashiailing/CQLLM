/**
 * @name Number of commits
 * @description Calculates the total count of commits in the repository, ignoring artificial modifications
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// Import necessary CodeQL modules for Python and version control system analysis
import python
import external.VCS

// Retrieve all commit entries from the repository
from Commit commitEntry
// Filter out commits that represent artificial changes
where not artificialChange(commitEntry)
// Return the revision identifier and a count value of 1 for each valid commit
select commitEntry.getRevisionName(), 1