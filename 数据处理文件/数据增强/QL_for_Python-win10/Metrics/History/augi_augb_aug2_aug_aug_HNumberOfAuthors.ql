/**
 * @name Number of authors
 * @description Computes the quantity of distinct contributors who have made changes
 *              to each Python file. This metric assists in identifying files with
 *              extensive collaboration patterns or possible knowledge silo risks.
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
from Module sourceFile
// Ensure we only process modules that contain actual code
where exists(sourceFile.getMetrics().getNumberOfLinesOfCode())
// Calculate and return the count of unique contributors for each Python module
select sourceFile,
       count(Author codeContributor | codeContributor.getAnEditedFile() = sourceFile.getFile())