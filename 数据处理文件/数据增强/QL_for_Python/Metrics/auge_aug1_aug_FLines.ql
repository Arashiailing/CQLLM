/**
 * @name Python Module Size Analysis
 * @description Measures and presents the line count for each Python module in the project.
 * @kind treemap
 * @id py/lines-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python

from Module moduleFile, int moduleLines
where moduleLines = moduleFile.getMetrics().getNumberOfLines()
select moduleFile, moduleLines order by moduleLines desc