/**
 * @name File Line Count Analysis
 * @description Calculates and displays the number of lines in each Python file.
 *              This metric helps identify potentially large files that might
 *              need refactoring or further investigation.
 * @kind treemap
 * @id py/lines-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python

// Analyze line count metrics for Python source files
from Module sourceFile, int totalLines
where 
    // Extract the line count metric for each module
    totalLines = sourceFile.getMetrics().getNumberOfLines()
select 
    // Display each module with its line count, sorted in descending order
    sourceFile, totalLines 
order by 
    totalLines desc