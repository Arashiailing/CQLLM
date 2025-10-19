/**
 * @name Source links of commits
 * @description Identifies source files affected by commits and provides their revision information.
 *              This query helps track which source code files were modified in each commit.
 *              It establishes a relationship between commits and the source files they impact,
 *              enabling developers to trace changes across the codebase.
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 */

// Import Python library for code analysis capabilities
import python
// Import VCS library for version control system functionality
import external.VCS

// Define the main query to analyze commit-file relationships
from Commit commitRecord, File modifiedFile
where 
  // Ensure we only process actual source code files
  modifiedFile.fromSource() and
  // Establish the relationship between commit and affected source file
  modifiedFile = commitRecord.getAnAffectedFile()
// Return commit revision identifier and corresponding source file
select commitRecord.getRevisionName(), modifiedFile