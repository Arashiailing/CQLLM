/**
 * @name Python file comment line ratio analysis
 * @description Calculates the percentage of comment lines (excluding docstrings) 
 *              relative to total lines in Python source files. This metric helps 
 *              assess code documentation quality and maintainability.
 * @kind treemap
 * @id py/comment-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

from Module fileModule
where fileModule.getMetrics().getNumberOfLines() > 0
select fileModule,
       100.0 * fileModule.getMetrics().getNumberOfLinesOfComments() / fileModule.getMetrics().getNumberOfLines() as commentPercentage
order by commentPercentage desc