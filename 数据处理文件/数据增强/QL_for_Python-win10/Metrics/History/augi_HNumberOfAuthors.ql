/**
 * @name Number of authors
 * @description Number of distinct authors for each file
 * @kind treemap
 * @id py/historical-number-of-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

// Import Python language module for code parsing and analysis capabilities
import python
// Import external version control system (VCS) module to access commit history and author information
import external.VCS

// Define the query source: select file modules from the codebase
from Module fileModule
// Apply filter condition: only consider modules that have lines of code metrics available
where exists(fileModule.getMetrics().getNumberOfLinesOfCode())
// Select the file module and count the number of distinct authors who have contributed to it
select fileModule, count(Author fileAuthor | fileAuthor.getAnEditedFile() = fileModule.getFile())