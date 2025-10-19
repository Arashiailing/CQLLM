/**
 * @name Source links of commits
 * @description Identifies and extracts source code files associated with each commit in the version control system.
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 */

// Import Python analysis module to enable Python-specific code analysis capabilities
import python
// Import external version control system module for accessing commit history and file modification details
import external.VCS

// Extract commit entries and their associated modified source files from the version control system
from Commit commitEntry, File modifiedSourceFile
// Filter condition 1: Ensure we only process source code files
where modifiedSourceFile.fromSource()
// Filter condition 2: Verify the file was actually affected by the commit
and modifiedSourceFile = commitEntry.getAnAffectedFile()
// Output the commit revision identifier and the affected source code file
select commitEntry.getRevisionName(), modifiedSourceFile