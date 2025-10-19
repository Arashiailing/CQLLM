/**
 * @name Comment line percentage analysis
 * @description Calculates the ratio of comment lines to total lines in a Python file.
 *              Docstrings are excluded from this metric and handled separately.
 * @kind treemap
 * @id py/comment-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

from Module m
where m.getMetrics().getNumberOfLines() > 0
select m, 100.0 * m.getMetrics().getNumberOfLinesOfComments() / m.getMetrics().getNumberOfLines() as ratio
order by ratio desc