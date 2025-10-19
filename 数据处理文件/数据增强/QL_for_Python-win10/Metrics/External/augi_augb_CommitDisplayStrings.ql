/**
 * @name Commit Information Display
 * @description Displays comprehensive commit details from the version control system,
 *              presenting unique revision identifiers along with commit messages
 *              and their corresponding timestamps in a formatted manner.
 * @kind display-string
 * @id py/commit-display-strings
 * @metricType commit
 */

import python  // Enables Python code analysis capabilities
import external.VCS  // Provides access to version control system data

// Retrieve all commit entries from the version control system
from Commit commitEntry

// Format output: First column shows the unique revision identifier,
// Second column combines commit message with timestamp in parentheses
select commitEntry.getRevisionName(), commitEntry.getMessage() + "(" + commitEntry.getDate().toString() + ")"