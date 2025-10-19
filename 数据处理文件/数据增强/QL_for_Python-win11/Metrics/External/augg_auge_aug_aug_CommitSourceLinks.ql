/**
 * @name Commit to source file mapping
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 * @description Creates associations between version control commits and their related
 *              source files by examining commit information and monitoring file changes
 *              throughout the repository's version history.
 */

// Import Python analysis capabilities
import python
// Import version control system functionality for commit tracking and file modification history
import external.VCS

// Query to extract commit records and their associated modified source files
from Commit commitObj, File modifiedSourceFile
// Establish the relationship between commit and modified file
where modifiedSourceFile = commitObj.getAnAffectedFile()
// Filter to include only source code files
and modifiedSourceFile.fromSource()
// Output commit revision identifier along with the corresponding source file
select commitObj.getRevisionName(), modifiedSourceFile