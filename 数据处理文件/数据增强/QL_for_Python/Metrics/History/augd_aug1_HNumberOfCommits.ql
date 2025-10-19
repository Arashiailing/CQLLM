/**
 * @name Number of commits
 * @description Provides a quantitative analysis of commit activity within the repository,
 *              systematically excluding artificial changes to ensure accurate tracking
 *              of genuine development contributions over time.
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// Import Python language support for code analysis context
import python
// Import version control system (VCS) functionality for historical data access
import external.VCS

// Source: iterate through each commit entity in the repository history
from Commit commitEntry
// Filter: exclude commits identified as artificial changes to maintain data integrity
where not artificialChange(commitEntry)
// Projection: extract revision identifier and assign unit count for metric aggregation
select commitEntry.getRevisionName(), 1