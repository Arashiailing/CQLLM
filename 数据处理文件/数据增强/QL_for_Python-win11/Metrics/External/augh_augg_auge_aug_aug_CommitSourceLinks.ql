/**
 * @name Commit to source file mapping
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 * @description Establishes a comprehensive mapping between version control commits and
 *              their corresponding source files. This query analyzes commit metadata
 *              and tracks file modifications across the repository's version control
 *              history to create meaningful associations. The output provides a direct
 *              link between each commit's revision identifier and the source files
 *              that were modified in that commit.
 */

// Import Python analysis capabilities for source code identification and processing
import python
// Import version control system (VCS) functionality for tracking commit history and file modifications
import external.VCS

// Extract commit records and identify their affected source files
from Commit commitRecord, File affectedSourceFile
// Establish relationship: file must be affected by the commit
where affectedSourceFile = commitRecord.getAnAffectedFile()
// Restrict results to actual source code files only, excluding documentation, tests, or other non-source files
and affectedSourceFile.fromSource()
// Return the commit revision identifier along with the associated source file path for traceability
select commitRecord.getRevisionName(), affectedSourceFile