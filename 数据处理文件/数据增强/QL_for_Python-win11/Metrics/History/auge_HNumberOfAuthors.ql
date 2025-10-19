/**
 * @name Number of authors
 * @description Calculates the count of distinct contributors who have modified each Python file.
 *              This metric helps identify files with high collaboration or potential knowledge silos.
 * @kind treemap
 * @id py/historical-number-of-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

// Import Python module for parsing and analyzing Python code structures
import python
// Import external Version Control System (VCS) module to access commit history and author information
import external.VCS

// Define the source of our analysis: Python modules representing files
from Module fileModule
// Apply filtering condition to ensure we only analyze files with actual code content
where exists(fileModule.getMetrics().getNumberOfLinesOfCode())
// Project the file module along with the count of distinct authors who have modified it
select fileModule, 
       count(Author fileAuthor | 
             fileAuthor.getAnEditedFile() = fileModule.getFile()
       )