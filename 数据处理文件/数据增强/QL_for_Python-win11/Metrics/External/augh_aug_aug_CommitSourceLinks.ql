/**
 * @name Commit-to-source file associations
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 * @description Establishes connections between version control commits and the source files
 *              they modify by analyzing the commit history and tracking file modifications
 *              across different revisions of the codebase.
 */

// Import Python module to enable Python code analysis capabilities
import python
// Import external version control system module for accessing commit history and file change information
import external.VCS

// Define variables to represent commit records and affected source files
from Commit commitRecord, File affectedSourceFile
// Apply filtering conditions to ensure we only process legitimate source files that were modified in commits
where 
  // Confirm that the file is a source code file
  affectedSourceFile.fromSource() and
  // Verify the file was actually modified in the specified commit
  affectedSourceFile = commitRecord.getAnAffectedFile()
// Output the commit revision identifier and the corresponding affected source file
select commitRecord.getRevisionName(), affectedSourceFile