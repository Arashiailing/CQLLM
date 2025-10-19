/**
 * @name File-level Line Addition Analysis
 * @description Calculates the total number of lines added to each file throughout the revision history stored in the database.
 * @kind treemap
 * @id py/historical-lines-added
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

// Import Python module for handling Python code analysis
import python
// Import external Version Control System (VCS) module for accessing version control data
import external.VCS

// Select data from Module fileModule and integer totalAddedLines
from Module fileModule, int totalAddedLines
where
  // Ensure the module has lines of code metrics available
  exists(fileModule.getMetrics().getNumberOfLinesOfCode()) and
  // Calculate the total number of added lines for each file and assign it to variable totalAddedLines
  totalAddedLines =
    sum(Commit versionCommit, int addedLinesCount |
      // Retrieve the number of lines added in the most recent commit for the file, excluding artificial changes
      addedLinesCount = versionCommit.getRecentAdditionsForFile(fileModule.getFile()) and 
      not artificialChange(versionCommit)
    |
      // Accumulate the number of added lines
      addedLinesCount
    )
select fileModule, totalAddedLines order by totalAddedLines desc // Order results by number of added lines in descending order