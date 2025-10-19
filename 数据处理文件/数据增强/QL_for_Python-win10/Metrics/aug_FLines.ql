/**
 * @name Number of lines
 * @description Provides a count of lines for every Python module in the codebase.
 * @kind treemap
 * @id py/lines-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python

from Module mod, int numLines
where numLines = mod.getMetrics().getNumberOfLines()
select mod, numLines order by numLines desc