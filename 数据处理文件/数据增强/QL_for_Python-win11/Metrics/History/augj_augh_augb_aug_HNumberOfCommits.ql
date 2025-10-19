/**
 * @name Commit Counter Analysis
 * @description Provides a count of all authentic commits in the repository, filtering out artificial modifications
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// Import necessary Python analysis capabilities
import python

// Import VCS (Version Control System) libraries to interact with repository history
import external.VCS

// Define the data source and apply filters
from Commit revisionRecord
where not artificialChange(revisionRecord)

// Generate output: revision identifier and count value
select revisionRecord.getRevisionName(), 1