/**
 * @name Commit Count Analysis
 * @description Quantifies the total commits in the repository, excluding synthetic modifications
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// Import Python language module for analysis context
import python
// Import version control system utilities for commit tracking
import external.VCS

// Analyze each commit record in the version history
from Commit commitRecord
// Exclude commits that are flagged as artificial (e.g., automated refactoring, style adjustments)
where not artificialChange(commitRecord)
// Return the revision identifier and count each valid commit as a single unit
select commitRecord.getRevisionName(), 1