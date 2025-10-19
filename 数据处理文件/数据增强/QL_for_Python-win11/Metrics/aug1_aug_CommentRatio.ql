/**
 * @name Python file comment density measurement
 * @description Measures the density of comment lines relative to total lines in Python source files.
 *              Note that docstrings are not included in this calculation and are processed independently.
 * @kind treemap
 * @id py/comment-density-per-file
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
       100.0 * pyModule.getMetrics().getNumberOfLinesOfComments() / pyModule.getMetrics().getNumberOfLines() as commentDensity
order by commentDensity desc