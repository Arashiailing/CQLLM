/**
 * @name Python File Line Count Assessment
 * @description Computes and presents the line count for every Python file.
 *              This measurement assists in recognizing sizable files that could
 *              require restructuring or additional examination.
 * @kind treemap
 * @id py/lines-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python

// Identify Python modules and their corresponding line counts
from Module pythonModule, int numLines

// Calculate line count for each module
where numLines = pythonModule.getMetrics().getNumberOfLines()

// Display results sorted by line count (highest first)
select pythonModule, numLines 
order by numLines desc