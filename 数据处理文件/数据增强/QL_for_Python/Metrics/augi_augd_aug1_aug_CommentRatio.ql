/**
 * @name Python source file comment density analysis
 * @description Calculates the ratio of comment lines to total lines in Python source files.
 *              This metric helps assess code documentation quality. Docstrings are excluded
 *              from this calculation as they are treated as a separate documentation category.
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