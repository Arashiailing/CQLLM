/**
 * @name Repository Commit Count Analysis
 * @description Calculates total commit volume in codebase, filtering out synthetic modifications
 * @kind treemap
 * @id py/historical-commit-volume
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// Import Python analysis framework
import python
// Import version control system interfaces
import external.VCS

// Source: Retrieve all commit entries
from Commit commitEntry
// Filter: Exclude commits representing non-human modifications
where 
  not artificialChange(commitEntry)
// Output: Extract revision identifier with unit value for aggregation
select commitEntry.getRevisionName(), 1