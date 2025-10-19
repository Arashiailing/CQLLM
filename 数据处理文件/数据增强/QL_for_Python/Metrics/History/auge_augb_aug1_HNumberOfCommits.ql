/**
 * @name Number of commits
 * @description Counts the number of commits in the repository, excluding artificial changes
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// Import Python language support module
import python
// Import version control system (VCS) functionality for commit analysis
import external.VCS

// Analyze each commit record in the repository
from Commit commitRecord
// Exclude commits that are marked as artificial changes (e.g., automated formatting, import restructuring)
where not artificialChange(commitRecord)
// Output the revision identifier and count each commit as one unit
select commitRecord.getRevisionName(), 1