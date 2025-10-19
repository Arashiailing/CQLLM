/**
 * @name Python source file comment density analysis
 * @description This analysis calculates the percentage of comment lines relative to the total lines
 *              in Python source files. Note that docstrings are excluded from this calculation
 *              as they are considered separately from standard comments.
 * @kind treemap
 * @id py/comment-density-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

from Module pyFile
where 
  // Only consider files that have at least one line of code
  pyFile.getMetrics().getNumberOfLines() > 0
select 
  pyFile,
  // Calculate comment density as a percentage
  (100.0 * pyFile.getMetrics().getNumberOfLinesOfComments()) / pyFile.getMetrics().getNumberOfLines() as commentRatio
order by 
  commentRatio desc