/**
 * @name Source links of commits
 * @description Identifies source files affected by commits and provides their revision information.
 *              This query helps track which source code files were modified in each commit,
 *              enabling developers to understand the scope of changes across the codebase.
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 */

// Import core Python analysis module for code analysis capabilities
import python
// Import version control system integration module for commit tracking
import external.VCS

// Select revision and affected source file pairs for analysis
from Commit revision, File sourceFile
where 
  // Establish relationship between revision and affected source file
  sourceFile = revision.getAnAffectedFile() and
  // Filter to include only source code files, excluding documentation and configuration files
  sourceFile.fromSource()
// Return revision identifier and corresponding source file path
select revision.getRevisionName(), sourceFile