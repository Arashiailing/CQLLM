/**
 * @name Python source file comment density evaluation
 * @description Calculates the ratio of comment lines to total lines in Python source files.
 *              This analysis excludes docstrings, which are processed as a separate metric.
 * @kind treemap
 * @id py/comment-density-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

from Module sourceModule
where sourceModule.getMetrics().getNumberOfLines() > 0
select sourceModule, 
       (100.0 * sourceModule.getMetrics().getNumberOfLinesOfComments()) / sourceModule.getMetrics().getNumberOfLines() as commentDensity
order by commentDensity desc