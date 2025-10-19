/**
 * @name Source links of commits
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 */

// Import Python module to enable Python code analysis capabilities
import python
// Import external version control system module for accessing commit history and file modifications
import external.VCS

// Retrieve commit entries and their associated source files from version control
from Commit commitEntry, File sourceFile
// Filter to include only source code files that were modified in the commit
where sourceFile.fromSource() and sourceFile = commitEntry.getAnAffectedFile()
// Return the commit revision identifier along with the affected source file
select commitEntry.getRevisionName(), sourceFile