/**
 * @name Number of commits
 * @description Quantifies total commits in repository, excluding artificial changes
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// Import required modules for Python analysis and version control system access
import python
import external.VCS

// Source: Fetch all commit records from repository history
// Filter: Exclude commits flagged as artificial changes (e.g., automated merges/rebases)
from Commit commitEntry
where not artificialChange(commitEntry)
// Selection: Extract revision identifier for each valid commit with count value 1
select commitEntry.getRevisionName(),
       1