/**
 * @name Number of authors
 * @description Counts distinct contributors for each Python source file
 * @kind treemap
 * @id py/historical-number-of-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

// Import Python language analysis support for code structure parsing
import python
// Import version control system module for file history and contributor data
import external.VCS

// Define Python file variable representing source files to analyze
from Module pythonFile
// Filter for Python files containing measurable lines of code
where exists(pythonFile.getMetrics().getNumberOfLinesOfCode())
// Calculate and return the count of unique contributors per Python file
select pythonFile, count(Author contributor | contributor.getAnEditedFile() = pythonFile.getFile())