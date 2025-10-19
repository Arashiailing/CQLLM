/**
 * @name Repository Commit Count Analysis
 * @description Analyzes and counts the total commits in a repository, filtering out artificial changes
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

// Define the source data: retrieve all commit records from the repository
from Commit repoCommit
// Apply filtering criteria: exclude commits that represent artificial or synthetic changes
where not artificialChange(repoCommit)
// Generate output: extract the revision identifier for each commit and assign a count value of 1
select repoCommit.getRevisionName(), 1