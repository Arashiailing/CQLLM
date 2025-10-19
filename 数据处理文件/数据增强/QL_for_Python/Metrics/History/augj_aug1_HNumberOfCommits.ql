/**
 * @name Number of commits
 * @description Counts the number of commits in the repository, excluding artificial changes
 * @kind treemap
 * @id py/historical-number-of-commits
 * @treemap.warnOn highValues
 * @metricType commit
 * @metricAggregate sum
 */

// Import required modules for Python and version control analysis
import python
import external.VCS

// Process repository commit entries, filtering out artificial changes
from Commit commitEntry
where 
  // Exclude commits marked as artificial changes to count only genuine commits
  not artificialChange(commitEntry)
select 
  // Retrieve the revision identifier for each valid commit
  commitEntry.getRevisionName(), 
  // Assign a count value of 1 to each commit for metric aggregation
  1