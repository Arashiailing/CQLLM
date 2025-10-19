/**
 * @name Mapping Commits to Source Files
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 * @description Establishes connections between version control commits and the source
 *              files they modify by analyzing commit data and tracking file modifications
 *              across the repository's version control history.
 */

// Import Python code analysis features
import python
// Import version control system capabilities for tracking commits and file changes
import external.VCS

// Query that retrieves commit information and related modified source files
from Commit vcsCommit, File sourceFile
where sourceFile.fromSource() and sourceFile = vcsCommit.getAnAffectedFile()
// Display the commit revision identifier and the associated source file
select vcsCommit.getRevisionName(), sourceFile