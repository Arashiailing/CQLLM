/**
 * @name Python Module Size Analysis
 * @description Calculates and displays the number of lines in each Python module within the project.
 * @kind treemap
 * @id py/lines-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python

from Module pythonFile, int lineCount
where lineCount = pythonFile.getMetrics().getNumberOfLines()
select pythonFile, lineCount order by lineCount desc