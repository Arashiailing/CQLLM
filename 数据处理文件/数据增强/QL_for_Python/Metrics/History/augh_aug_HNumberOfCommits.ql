/**
 * @name Number of commits
 * @description Quantifies the total commit count in the repository, excluding artificial changes
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// Import Python language support for analysis
import python
// Import Version Control System (VCS) libraries to access commit history
import external.VCS

// Define data source: retrieve all commit records
from Commit commitRecord
// Apply filtering: exclude commits representing artificial changes
where not artificialChange(commitRecord)
// Generate output: extract revision identifier and assign unit count for aggregation
select commitRecord.getRevisionName(), 1