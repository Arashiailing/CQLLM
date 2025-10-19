/**
 * @name Source links of commits
 * @description Identifies source code files modified in each commit with their revision information.
 *              This analysis provides visibility into which source files were altered by specific commits.
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 */

// Import Python analysis library
import python
// Import version control system library
import external.VCS

// Select commit and modified file entities
from Commit commitRef, File modifiedFile
where 
  // Establish the relationship between commit and modified file
  modifiedFile = commitRef.getAnAffectedFile() and
  // Ensure we only include actual source code files
  modifiedFile.fromSource()
// Output commit revision identifier and the corresponding modified file
select commitRef.getRevisionName(), modifiedFile