/**
 * @name Number of commits
 * @description Computes the aggregate count of authentic commits in the repository, disregarding synthetic commits
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// Import necessary CodeQL libraries for Python code analysis and version control system tracking
import python
import external.VCS

// Fetch all legitimate commits from the version control history,
// excluding those that are artificially generated or automated
from Commit commitEntry
where not artificialChange(commitEntry)
// Emit the revision identifier and a count value of 1 for each qualifying commit
select commitEntry.getRevisionName(), 1