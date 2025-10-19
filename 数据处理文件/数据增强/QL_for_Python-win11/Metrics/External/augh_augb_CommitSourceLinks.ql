/**
 * @name Source links of commits
 * @description Tracks source files modified in commits and provides their revision details.
 *              This query enables identification of all source code files impacted by each commit.
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 */

// Import Python library for code analysis capabilities
import python
// Import VCS library for version control system functionality
import external.VCS

// Select commit and file entities for analysis
from Commit revision, File sourceFile
where 
  // Filter to include only source code files
  sourceFile.fromSource() and
  // Establish relationship between commit and affected file
  sourceFile = revision.getAnAffectedFile()
// Return commit revision identifier and corresponding file
select revision.getRevisionName(), sourceFile