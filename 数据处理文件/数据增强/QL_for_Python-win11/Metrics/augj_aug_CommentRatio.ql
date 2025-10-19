/**
 * @name Code Comment Density Analysis
 * @description Computes the density of comment lines relative to total lines in Python source files.
 *              Note that docstrings are not considered in this calculation and are processed independently.
 * @kind treemap
 * @id py/comment-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

from Module pyModule, int totalLines, int commentLines
where 
  totalLines = pyModule.getMetrics().getNumberOfLines() and
  totalLines > 0 and
  commentLines = pyModule.getMetrics().getNumberOfLinesOfComments()
select pyModule, 100.0 * commentLines / totalLines as ratio
order by ratio desc