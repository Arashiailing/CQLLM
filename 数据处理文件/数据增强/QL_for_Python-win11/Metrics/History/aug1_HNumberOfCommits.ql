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

// Process each commit record
from Commit commitRecord
// Exclude commits marked as artificial changes
where not artificialChange(commitRecord)
// Select revision identifier and count each commit as 1
select commitRecord.getRevisionName(), 1