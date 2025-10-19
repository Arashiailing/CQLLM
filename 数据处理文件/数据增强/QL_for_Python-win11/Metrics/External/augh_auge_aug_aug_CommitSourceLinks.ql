/**
 * @name Commit-Source File Associations
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 * @description Identifies and maps relationships between version control commits and their
 *              associated source files by examining commit metadata and tracking file
 *              modifications throughout the repository's history.
 */

// Import Python-specific code analysis capabilities
import python
// Import version control system data including commit history and file modification tracking
import external.VCS

// Query structure: fetch commit records and their corresponding modified source files
from Commit commitRecord, File modifiedSourceFile
// Ensure the file is a valid source code file and establish direct association with the commit
where modifiedSourceFile.fromSource() and 
      modifiedSourceFile = commitRecord.getAnAffectedFile()
// Output results containing commit identifier and the associated source file
select commitRecord.getRevisionName(), modifiedSourceFile