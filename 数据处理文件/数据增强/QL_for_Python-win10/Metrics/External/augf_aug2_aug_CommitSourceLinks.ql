/**
 * @name Source links of commits
 * @description Identifies source code files modified in each commit
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 */

// Import Python analysis module for code parsing capabilities
import python
// Import version control integration for accessing commit history and change tracking
import external.VCS

// Retrieve all commit records along with their associated source file changes
from Commit codeCommit, File changedSourceFile
where 
  // Filter to include only source code files, excluding tests, documentation, and other non-source files
  changedSourceFile.fromSource() and
  // Ensure the file was actually modified in this specific commit
  changedSourceFile = codeCommit.getAnAffectedFile()
// Return the commit revision identifier along with the affected source code file
select codeCommit.getRevisionName(), changedSourceFile