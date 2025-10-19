/**
 * @name Module Line Count
 * @description Calculates and displays the line count for each Python module in the codebase.
 * @kind treemap
 * @id py/lines-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python

from Module pythonModule, int lineCount
where lineCount = pythonModule.getMetrics().getNumberOfLines()
select pythonModule, lineCount order by lineCount desc