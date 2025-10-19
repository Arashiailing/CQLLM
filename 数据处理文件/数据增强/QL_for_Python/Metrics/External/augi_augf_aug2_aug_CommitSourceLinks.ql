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

// Query to identify source code files modified in each commit
from Commit commitRecord, File modifiedFile
where 
  // Restrict to source code files only (exclude tests, docs, etc.)
  modifiedFile.fromSource() and
  // Verify the file was modified in the specific commit
  modifiedFile = commitRecord.getAnAffectedFile()
// Output: Commit revision identifier and the modified source code file
select commitRecord.getRevisionName(), modifiedFile