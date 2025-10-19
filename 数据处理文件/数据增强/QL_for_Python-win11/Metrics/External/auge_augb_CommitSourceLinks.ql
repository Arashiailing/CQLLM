/**
 * @name Source links of commits
 * @description Identifies source files affected by commits and provides their revision information.
 *              This query helps track which source code files were modified in each commit.
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 */

// Import core Python analysis module
import python
// Import version control system integration module
import external.VCS

// Select commit and affected source file pairs
from Commit commit, File affectedFile
where 
  // Establish relationship between commit and affected file
  affectedFile = commit.getAnAffectedFile() and
  // Filter to include only source code files
  affectedFile.fromSource()
// Return commit revision identifier and corresponding file
select commit.getRevisionName(), affectedFile