/**
 * @name Python source code comment ratio evaluation
 * @description Measures the percentage of comment lines relative to total lines in Python modules.
 *              Docstrings are excluded from this calculation as they serve a different purpose
 *              than regular code comments.
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
       (100.0 * pyModule.getMetrics().getNumberOfLinesOfComments()) / pyModule.getMetrics().getNumberOfLines() as density
order by density desc