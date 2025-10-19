/**
 * @name Source links of commits
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 * @description Establishes connections between version control commits and their corresponding
 *              source files by analyzing commit metadata and tracking file modifications
 *              across the repository's history.
 */

// Enable Python-specific code analysis functionality
import python
// Access version control system data including commit history and file change tracking
import external.VCS

// Query structure: retrieve commit records and associated modified files
from Commit commitEntry, File affectedSourceFile
// Validate that the file is a legitimate source code file within the project
where affectedSourceFile.fromSource()
// Establish direct relationship between commit and file modification
and affectedSourceFile = commitEntry.getAnAffectedFile()
// Return formatted results with commit identifier and the corresponding source file
select commitEntry.getRevisionName(), affectedSourceFile