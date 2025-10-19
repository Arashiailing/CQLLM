/**
 * @name Display strings of commits
 * @kind display-string
 * @id py/commit-display-strings
 * @metricType commit
 * @description Extracts and displays commit information from the version control system.
 *              For each commit, the query presents the revision identifier and a formatted
 *              string that combines the commit message with its timestamp. This provides
 *              developers with a concise view of the project's commit history.
 */

import python  // Import the Python library for handling Python code analysis
import external.VCS  // Import the external Version Control System (VCS) library
                    // for accessing version control related data

// Retrieve all commit entries from the version control system
from Commit commitEntry
// Format the output to display the revision name and a composite string
// containing the commit message and date (in parentheses)
select commitEntry.getRevisionName(), 
       commitEntry.getMessage() + "(" + commitEntry.getDate().toString() + ")"