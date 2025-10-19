/**
 * @name Number of authors
 * @description Calculates the count of unique contributors who have modified each Python file.
 *              This metric helps identify files with high collaboration activity or potential
 *              knowledge concentration risks.
 * @kind treemap
 * @id py/historical-number-of-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

// Import Python language analysis support for parsing Python code structures
import python
// Import version control system module to access file history and contributor information
import external.VCS

// Define the source of Python modules to analyze
from Module pythonModule
// Filter to include only modules that have measurable code lines
where exists(pythonModule.getMetrics().getNumberOfLinesOfCode())
// Calculate and return the count of unique contributors for each Python module
select pythonModule, 
       count(Author contributor | contributor.getAnEditedFile() = pythonModule.getFile())