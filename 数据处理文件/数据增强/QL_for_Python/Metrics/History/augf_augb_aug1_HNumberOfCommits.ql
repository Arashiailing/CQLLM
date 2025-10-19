/**
 * @name Number of commits
 * @description Calculates the total number of commits in the repository, 
 *              excluding changes marked as artificial
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// Import necessary Python language modules
import python
// Import version control system (VCS) related capabilities
import external.VCS

// Define the source of data: all commit records
from Commit commitRecord

// Apply filtering condition: exclude artificial changes
where not artificialChange(commitRecord)

// Generate output: revision identifier and count (1 per commit)
select commitRecord.getRevisionName(), 1