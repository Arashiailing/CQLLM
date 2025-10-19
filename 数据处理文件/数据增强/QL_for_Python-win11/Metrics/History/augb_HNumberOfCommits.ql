/**
 * @name Number of commits
 * @description Counts the total number of commits in the repository, excluding artificial changes
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// Import required CodeQL libraries for Python and version control analysis
import python
import external.VCS

// Query all commit records while filtering out artificial changes
from Commit commitRecord
where not artificialChange(commitRecord)
// Output revision identifier and count value (1 per commit)
select commitRecord.getRevisionName(), 1