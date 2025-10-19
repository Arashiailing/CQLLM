/**
 * @name Python file comment density analysis
 * @description Computes the percentage of comment lines relative to the total lines in a Python module.
 *              Note that docstrings are not counted as comments and are evaluated separately.
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
       (100.0 * pyModule.getMetrics().getNumberOfLinesOfComments()) / pyModule.getMetrics().getNumberOfLines() as commentRatio
order by commentRatio desc