/**
 * @name Source links of commits
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 * @description Identifies and maps the relationship between version control commits
 *              and their associated source code files. This query analyzes commit
 *              metadata to track file modifications throughout the repository's
 *              history, providing a comprehensive view of code changes.
 */

// Enable Python-specific code analysis functionality
import python
// Access version control system data including commit history and file change tracking
import external.VCS

// Main query: identify commits and their modified source files
from Commit commitRecord, File modifiedSourceFile
where 
    // Ensure the file is a legitimate source code file
    modifiedSourceFile.fromSource() and
    // Link the file to the commit that modified it
    modifiedSourceFile = commitRecord.getAnAffectedFile()
// Output commit identifier and the corresponding source file
select commitRecord.getRevisionName(), modifiedSourceFile