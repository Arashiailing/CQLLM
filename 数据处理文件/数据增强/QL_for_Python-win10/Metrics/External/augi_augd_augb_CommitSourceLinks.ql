/**
 * @name Source links of commits
 * @description Maps source files to their corresponding commits, providing revision details.
 *              This analysis enables tracking of source code modifications at the commit level,
 *              establishing a clear link between version control changes and affected files.
 *              Developers can utilize this to trace the evolution of specific code segments.
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 */

// Import Python library for code analysis capabilities
import python
// Import VCS library for version control system functionality
import external.VCS

// Primary query to establish relationships between commits and source files
from Commit commitEntry, File affectedSourceFile
where 
  // Filter for source code files only
  affectedSourceFile.fromSource() and
  // Link the source file to commits that modified it
  affectedSourceFile = commitEntry.getAnAffectedFile()
// Output the commit revision identifier and the affected source file
select commitEntry.getRevisionName(), affectedSourceFile