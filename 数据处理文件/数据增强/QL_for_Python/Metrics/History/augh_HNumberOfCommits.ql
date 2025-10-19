/**
 * @name Number of commits
 * @description Counts the number of commits in the repository, excluding artificially generated changes
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// Import necessary Python language support module
import python
// Import version control system (VCS) functionality for commit analysis
import external.VCS

// Query to retrieve commit records from the version control system
from Commit commitEntry
// Filter out commits that represent artificial changes (e.g., automated formatting, imports)
where not artificialChange(commitEntry)
// Select the revision name of each commit and assign a count of 1 for aggregation purposes
select commitEntry.getRevisionName(), 1