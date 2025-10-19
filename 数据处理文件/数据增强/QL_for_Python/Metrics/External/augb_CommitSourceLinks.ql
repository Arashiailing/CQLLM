/**
 * @name Source links of commits
 * @description Identifies source files affected by commits and provides their revision information.
 *              This query helps track which source code files were modified in each commit.
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 */

// Import Python library for code analysis capabilities
import python
// Import VCS library for version control system functionality
import external.VCS

// Select commit and file entities for analysis
from Commit commitEntity, File fileEntity
where 
  // Filter to include only source code files
  fileEntity.fromSource() and
  // Establish relationship between commit and affected file
  fileEntity = commitEntity.getAnAffectedFile()
// Return commit revision identifier and corresponding file
select commitEntity.getRevisionName(), fileEntity