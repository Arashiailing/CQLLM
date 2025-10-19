/**
 * @name Number of authors
 * @description Counts the number of distinct contributors who have modified each Python file
 * @kind treemap
 * @id py/historical-number-of-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

// Import Python language module for code parsing and analysis capabilities
import python
// Import version control system API to access repository history data
import external.VCS

// Define the main query to analyze file authorship
from Module pythonFile
where 
  // Filter for files that have measurable lines of code
  pythonFile.getMetrics().getNumberOfLinesOfCode() > 0
select 
  // Output the file and count of distinct authors
  pythonFile, 
  count(Author codeContributor | 
    // Count authors who have edited this file
    codeContributor.getAnEditedFile() = pythonFile.getFile()
  )