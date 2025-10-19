/**
 * @name Number of authors
 * @description Computes the number of unique contributors who have made changes to each Python file.
 *              This metric is useful for identifying files with high collaboration levels or potential knowledge concentration.
 * @kind treemap
 * @id py/historical-number-of-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

// Import required modules for analysis
import python
import external.VCS

// Define the source of our analysis: Python modules representing files
from Module pyFile
// Apply filtering condition to ensure we only analyze files with actual code content
where exists(pyFile.getMetrics().getNumberOfLinesOfCode())
// Project the file module along with the count of distinct authors who have modified it
select pyFile, 
       count(Author contributor | 
             // An author is counted if they have edited this file
             contributor.getAnEditedFile() = pyFile.getFile()
       )