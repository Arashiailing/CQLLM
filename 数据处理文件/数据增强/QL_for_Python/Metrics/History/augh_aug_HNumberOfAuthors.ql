/**
 * @name Number of authors
 * @description Count of distinct contributors per Python source file
 * @kind treemap
 * @id py/historical-number-of-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

// Import Python language module for code parsing and analysis capabilities
import python
// Import external version control API to access repository history data
import external.VCS

// Define source file variable and filter for files with measurable code
from Module sourceFile
where exists(sourceFile.getMetrics().getNumberOfLinesOfCode())
// Compute the number of unique authors who have edited each file
select sourceFile, 
  count(Author contributor | 
    contributor.getAnEditedFile() = sourceFile.getFile()
  )