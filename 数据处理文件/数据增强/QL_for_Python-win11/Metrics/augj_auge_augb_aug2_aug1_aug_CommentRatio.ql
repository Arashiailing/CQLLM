/**
 * @name Python source code comment density evaluation
 * @description Computes the percentage of comment lines relative to the total lines in Python source files.
 *              This metric specifically considers regular comments while intentionally excluding
 *              docstrings, as they serve a distinct documentation purpose.
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
where 
  // Filter out empty modules to avoid division by zero
  pyModule.getMetrics().getNumberOfLines() > 0
select 
  pyModule,
  // Calculate comment density as a percentage value
  (100.0 * pyModule.getMetrics().getNumberOfLinesOfComments()) / pyModule.getMetrics().getNumberOfLines() as commentDensity
order by 
  commentDensity desc