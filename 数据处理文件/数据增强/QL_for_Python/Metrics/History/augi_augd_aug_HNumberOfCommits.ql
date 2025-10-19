/**
 * @name Commit Count Analysis
 * @description Calculates the total number of repository commits while filtering out artificial changes
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// Import necessary Python language modules for code analysis
import python

// Import external Version Control System (VCS) libraries to access historical commit data
import external.VCS

// Main query logic:
// 1. Data source: fetch all commit entries from the repository's history
// 2. Filtering condition: exclude commits that are marked as artificial or system-generated
// 3. Result projection: for each valid commit, output its revision identifier and a count value of 1 for aggregation
from Commit commitRecord
where not artificialChange(commitRecord)
select commitRecord.getRevisionName(), 1