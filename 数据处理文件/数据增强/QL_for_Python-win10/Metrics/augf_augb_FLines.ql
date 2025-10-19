/**
 * @name File Line Count Analysis
 * @description Calculates the total number of lines in each Python file module.
 * @kind treemap
 * @id py/lines-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python // Enables analysis of Python source code

// Define variables to represent Python file modules and their line counts
from Module pythonFile, int totalLines
// Calculate the total lines by retrieving metrics from each Python file
where totalLines = pythonFile.getMetrics().getNumberOfLines()
// Return results showing Python files and their line counts in descending order
select pythonFile, totalLines order by totalLines desc