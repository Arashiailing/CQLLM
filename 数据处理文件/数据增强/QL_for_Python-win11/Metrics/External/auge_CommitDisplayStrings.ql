/**
 * @name Display strings of commits
 * @kind display-string
 * @id py/commit-display-strings
 * @metricType commit
 * @description This query extracts commit information from the version control system (VCS)
 *              and displays each commit's revision name along with a formatted string
 *              containing the commit message and date. The output format is designed to
 *              provide a quick overview of commit activities in the codebase.
 */

import python  // Import the Python library for handling Python code analysis
import external.VCS  // Import the external Version Control System (VCS) library
                    // for accessing version control related data

// Query the Commit class to retrieve all commit records
from Commit commitRecord
// Format the output to show the revision name and a combined string of
// commit message and date (enclosed in parentheses)
select commitRecord.getRevisionName(), 
       commitRecord.getMessage() + "(" + commitRecord.getDate().toString() + ")"