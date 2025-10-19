/**
 * @name Number of commits
 * @description Calculates the total commit count within the repository, excluding artificial commits
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// Import required CodeQL modules for Python analysis and version control tracking
import python
import external.VCS

// Retrieve genuine development commits while filtering out artificial changes
from Commit commitRecord
where not artificialChange(commitRecord)
// Output revision identifier and count value for each valid commit
select commitRecord.getRevisionName(), 1