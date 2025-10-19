/**
 * @name Source links of commits
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 * @description Identifies and establishes links between code commits and their associated source files
 *              by extracting commit records from the version control system and correlating them
 *              with source code files that were modified in each commit.
 */

// Import Python module to enable Python code analysis capabilities
import python
// Import external version control system module for accessing commit history and file change information
import external.VCS

// Extract commit entries and their corresponding modified source files from the version control system
from Commit codeCommit, File modifiedSourceFile
// Verify that we are only processing legitimate source code files
where modifiedSourceFile.fromSource()
// Ensure the selected file was actually affected by the commit operation
and modifiedSourceFile = codeCommit.getAnAffectedFile()
// Output results: commit revision identifier and the affected source code file
select codeCommit.getRevisionName(), modifiedSourceFile