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

// Define Python module variable representing files to analyze
from Module analyzedModule
// Filter for modules with measurable lines of code
where exists(analyzedModule.getMetrics().getNumberOfLinesOfCode())
// Calculate and return count of unique contributors per module
select analyzedModule, count(Author fileContributor | fileContributor.getAnEditedFile() = analyzedModule.getFile())