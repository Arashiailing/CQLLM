/**
 * @name Version control commit to source file correlation
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 * @description Creates a detailed mapping between version control system commits and 
 *              the source files they modify. This query examines commit information 
 *              and monitors file changes throughout the repository's version history 
 *              to establish significant connections. The result delivers a direct 
 *              association between each commit's revision identifier and the source 
 *              files altered within that commit.
 */

// Import Python analysis capabilities for source code identification and processing
import python
// Import version control system (VCS) functionality for tracking commit history and file modifications
import external.VCS

// Define the source of our data: commits and their affected files
from Commit versionCommit, File modifiedSource
// Filter to ensure we only process actual source files affected by commits
where 
    // Establish the relationship between commit and affected file
    modifiedSource = versionCommit.getAnAffectedFile()
    // Limit results to source code files only, filtering out documentation, tests, and other non-source files
    and modifiedSource.fromSource()
// Output the commit revision identifier and the corresponding source file path for tracking purposes
select versionCommit.getRevisionName(), modifiedSource