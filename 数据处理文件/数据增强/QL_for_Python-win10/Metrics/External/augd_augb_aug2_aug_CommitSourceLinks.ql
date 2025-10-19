/**
 * @name Source links of commits
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 */

// Import Python analysis module for Python code parsing capabilities
import python
// Import version control system integration module for accessing commit history and change tracking
import external.VCS

// Identify all commit records and their corresponding source file modifications
from Commit commitRecord, File affectedSourceFile
where 
  // Verify that the file was actually modified in the commit
  affectedSourceFile = commitRecord.getAnAffectedFile()
  and
  // Filter to include only source code files, excluding non-source files like tests and documentation
  affectedSourceFile.fromSource()
// Output the commit revision identifier along with the affected source file
select commitRecord.getRevisionName(), affectedSourceFile