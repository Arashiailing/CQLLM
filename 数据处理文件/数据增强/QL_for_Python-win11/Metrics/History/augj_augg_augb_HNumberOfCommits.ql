/**
 * @name Number of commits
 * @description Calculates the total count of commits in the repository, ignoring artificial modifications
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// Import required CodeQL modules for Python and version control system analysis
import python
import external.VCS

// Define source: All commit records in the repository
from Commit commitRecord
// Apply filter: Exclude commits representing artificial changes
where not artificialChange(commitRecord)
// Output: Revision identifier and count value (1 per valid commit)
select 
  commitRecord.getRevisionName(), // First column: Commit revision identifier
  1                               // Second column: Unit count for aggregation