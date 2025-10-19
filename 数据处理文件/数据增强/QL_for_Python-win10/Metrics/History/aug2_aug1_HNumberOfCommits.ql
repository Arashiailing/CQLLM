/**
 * @name Commit Count Analysis
 * @description Quantifies repository commits by excluding artificial changes
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

// Process genuine commits while filtering artificial changes
from Commit commitEntry
where not artificialChange(commitEntry)
// Output revision identifier with unit count
select commitEntry.getRevisionName(), 1