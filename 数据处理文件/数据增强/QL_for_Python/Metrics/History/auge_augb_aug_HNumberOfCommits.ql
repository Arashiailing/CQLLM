/**
 * @name Number of commits
 * @description Counts the number of commits in the repository, excluding artificial changes
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// Import necessary modules for Python analysis and version control system access
import python
import external.VCS

// Source: Retrieve all commit entries from the repository's history
from Commit gitCommit
// Filter: Exclude commits that are marked as artificial changes (e.g., automated merges, rebases)
where not artificialChange(gitCommit)
// Selection: For each valid commit, extract its revision identifier and assign a count of 1
select gitCommit.getRevisionName(), 1