/**
 * @name Comment line percentage analysis
 * @description This analysis calculates the percentage of comment lines relative to the total lines in a Python file.
 *              Note that docstrings are excluded from this calculation and are processed as a separate metric.
 * @kind treemap
 * @id py/comment-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

from Module pyModule
where pyModule.getMetrics().getNumberOfLines() > 0
select pyModule, 
       100.0 * pyModule.getMetrics().getNumberOfLinesOfComments() / pyModule.getMetrics().getNumberOfLines() as commentRatio
order by commentRatio desc