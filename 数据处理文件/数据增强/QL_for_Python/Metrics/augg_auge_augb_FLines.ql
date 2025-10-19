/**
 * @name File Line Count Analysis
 * @description Calculates the total number of lines in each Python file module.
 * @kind treemap
 * @id py/lines-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python // Import Python module for code analysis capabilities

// Define variables to represent each Python module and its corresponding line count
from Module sourceFile, int totalLines
// Calculate the line count by retrieving metrics from each module
where totalLines = sourceFile.getMetrics().getNumberOfLines()
// Return the results with modules sorted by line count in descending order
select sourceFile, totalLines order by totalLines desc